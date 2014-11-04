xquery version "1.0-ml";
module namespace gdlib = "urn:cabi.org:namespace:module:lib:geodata";

import module namespace mem = "http://xqdev.com/in-mem-update" at '/MarkLogic/appservices/utils/in-mem-update.xqy';
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace gd= "http://namespaces.cabi.org/namespaces/cabi/geodata";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

declare variable $geodata-collection-name := "urn:cabi.org:id:collection:geodata";

declare variable $GEODATA-COLLECTIONS := ($geodata-collection-name);

(: ------------------------------------------------- :)

(: Get Geodata item from request body:)

declare function validate-geodata-item-for-insert() as element(gd:geodata-request-validation)
{
	let $body as element() := rhttp:get-xml-body()
	let $uri as xs:string := gdlib:generate-new-geodata-item-uri()
	let $get-geodata-by-id-service-uri as xs:string := "/geodata/id/{ $uri }"
	return
		if ($body instance of element(gd:geodata-item))
		then 
			if (gdlib:has-unique-alias($body))
			then
				element gd:geodata-request-validation 
				{
					attribute valid { fn:true() },
					gdlib:remove-document-uri-for-insert($body)
				}
			else
				element gd:geodata-request-validation 
				{
					attribute valid {fn:false()},
					attribute response-status-code { 409 },
					attribute response-status-code-message {"Conflict - Alias is not unique"},
					<e:errors>
						<e:resource-not-unique>
							<e:message>There are more than one geodata-items with the aliases provided</e:message>
						</e:resource-not-unique>
					</e:errors>
				}	
		else 
			element gd:geodata-request-validation 
			{
				attribute valid {fn:false()},
				attribute response-status-code {400},
				attribute response-status-code-message {"Bad Request"},
				<e:errors xmlns:e="http://namespaces.cabi.org/namespaces/errors">
					<e:malformed-body>
						<e:message>Malformed body for geodata item.</e:message>
					</e:malformed-body>
				</e:errors>
			}
};

declare function validate-geodata-item-for-update(
	$id as xs:string,
	$given-etag-value as xs:string
) as element(gd:geodata-request-validation)
{
	let $geodata-item as element (gd:geodata-item)? := gdlib:get-geodata-item-by-id ($id)
	let $body as element() := rhttp:get-xml-body()
	return
			if (fn:exists($geodata-item))
			then
				if (gdlib:etag-matches-current-value($id,$given-etag-value))
				then 
					(
						if ($body instance of element(gd:geodata-item))
						then(
							 if (gdlib:has-unique-alias($body, $id))
							 then
							  (
								let $doc-uri := gdlib:get-geodata-item-doc-uri($geodata-item)
								return 	(
											element gd:geodata-request-validation 
											{
												attribute valid { fn:true() },
												attribute document-uri { $doc-uri },
												$body
											}
										)
							   )
							else
								(
									element gd:geodata-request-validation 
									{
										attribute valid {fn:false()},
										attribute response-status-code { 409 },
										attribute response-status-code-message {"Conflict - Alias is not unique"},
										<e:errors>
											<e:resource-not-unique>
												<e:message>There are more than one geodata-items with the aliases provided</e:message>
											</e:resource-not-unique>
										</e:errors>
									}	
								)
							)
						else
							(
								element gd:geodata-request-validation 
								{
									attribute valid {fn:false()},
									attribute response-status-code {400},
									attribute response-status-code-message {"Bad Request"},
									<e:errors xmlns:e="http://namespaces.cabi.org/namespaces/errors">
										<e:malformed-body>
											<e:message>Malformed body for geodata item.</e:message>
										</e:malformed-body>
									</e:errors>
								}
							)
					)
				else
					(
						let $current-etag-value := gdlib:get-geodata-item-etag-value($id)
						return
							element gd:geodata-request-validation 
								{
									attribute valid {fn:false()},
									attribute response-status-code {409},
									attribute response-status-code-message {"Conflict"},
									<e:errors xmlns:e="http://namespaces.cabi.org/namespaces/errors">
										<e:etag-mismatch>
											<e:message>Incorrect ETag value for '{$id}'</e:message>
											<e:current-etag>"{$current-etag-value}"</e:current-etag>
											<e:given-etag>"{$given-etag-value}"</e:given-etag>
										</e:etag-mismatch>
									</e:errors>
								}
					)
			else
				element gd:geodata-request-validation 
				{
					attribute valid {fn:false()},
					attribute response-status-code {404},
					attribute response-status-code-message {"Not found"},
					<e:errors xmlns:e="http://namespaces.cabi.org/namespaces/errors">
						<e:resource-not-found>
							<e:message>Cannot find geodata item with ID '{$id}'</e:message>
							<e:id>{$id}</e:id>
						</e:resource-not-found>
					</e:errors>
				}
};


(: Public functions :)
(: 1. CRUD functions :)

declare function insert-geodata-item (
	$item as element(gd:geodata-item),
	$uri as xs:string
)
{
	let $doc-uri := "/geodata/item/" || $uri || ".xml"
	return 
		(
			xdmp:document-insert($doc-uri, $item, xdmp:default-permissions(),($GEODATA-COLLECTIONS)),
			xdmp:document-set-property($doc-uri,<gd:etag>{sem:uuid-string()}</gd:etag>)
		)
};

declare function get-geodata-item-by-id (
	$id as xs:string
) as element(gd:geodata-item)?
{
	fn:collection ($geodata-collection-name)/gd:geodata-item[gd:uri/text() = $id]
};

declare function get-geodata-item-by-alias (
	$alias as xs:string
) as element (gd:geodata-item)*
{
		if (fn:exists (fn:collection ($geodata-collection-name)/gd:geodata-item[gd:alias = $alias]))
		then	
			(
			  <geodata-item xmlns="http://namespaces.cabi.org/namespaces/cabi/geodata">
				{fn:collection($geodata-collection-name)/gd:geodata-item[gd:alias = $alias]/gd:uri}
			  </geodata-item>
			)
		else
			()
};

declare function update-geodata-item ( 
	$item as node(),
	$id as xs:string,
	$doc-uri as xs:string
) as xs:string
{

	let $geodata-item-to-update := set-document-uri($item,$id)
	let $new-etag-value :=sem:uuid-string()
	let $updated-document := xdmp:document-insert($doc-uri, $geodata-item-to-update, xdmp:default-permissions(),($GEODATA-COLLECTIONS))
	let $updated-document-props :=xdmp:document-set-property($doc-uri,<gd:etag>{$new-etag-value}</gd:etag>)
	return $new-etag-value
};

(: URI and document functions :)

declare function remove-document-uri-for-insert(
	$geodata-item as node()?
) as element(gd:geodata-item)
{
	let $geodata-elements := $geodata-item/*[not(self::gd:uri)]
	return element gd:geodata-item
		{
			$geodata-elements
		}
};	

declare function set-document-uri ( 
	$geodata-item as element(gd:geodata-item)?,
    $id as xs:string
)
{ 
  let $uri-node := <gd:uri>{$id}</gd:uri> 
  let $geodata-elements := $geodata-item/*[not(self::gd:uri)]
  return element gd:geodata-item
	{
		$uri-node,
		$geodata-elements
	}
};

declare function get-geodata-item-doc-uri(
	$geodata-item as element (gd:geodata-item)?
) as xs:string
{
	xdmp:node-uri($geodata-item)
};

declare function get-geodata-document-properties(
	$id as xs:string
) as node()?
{
	let $document-uri-to-delete := xdmp:node-uri(gdlib:get-geodata-item-by-id($id))
	return xdmp:document-properties($document-uri-to-delete)
};

declare function generate-new-geodata-item-uri(
) as xs:string
{
	let $uri := "urn:cabi.org:id:geodata:" || sem:uuid-string()
	return $uri
};

declare function urn-for-geodata-item-matches-id (
	$geodata-item as element(gd:geodata-item)?,
	$id as xs:string
) as xs:boolean
{
	if (fn:exists($geodata-item) and (fn:string($geodata-item/gd:uri) = $id))
	 then 
	 (
		fn:true()
	 )
	 else
	 (
		fn:false()
	 )
};

declare function has-unique-alias ( 
	$geodata-item as element (gd:geodata-item)
)
{
	has-unique-alias($geodata-item,())
};

declare function has-unique-alias ( 
	$geodata-item as element (gd:geodata-item),
	$id as xs:string?
) as xs:boolean
{
	let $count-of-aliases :=
		for $geodataAlias in ($geodata-item/gd:alias/fn:string())
		return fn:count(
			fn:collection ($geodata-collection-name)/gd:geodata-item[gd:alias/text() = $geodataAlias and (fn:not(fn:exists($id)) or gd:uri/text() != $id)]
		)
 
	return if (fn:sum($count-of-aliases) > 0) 
         then 
			fn:false()
         else 
			fn:true()
	
};

(: etag functions :)

declare function get-geodata-item-etag-value(
	$id as xs:string
) as xs:string
{
	let $current-etag-value := get-geodata-document-properties($id)//gd:etag/text()
	return $current-etag-value
};

declare function etag-matches-current-value(
	$id as xs:string,
	$etag-value-to-check as xs:string
)
{
	let $current-etag := get-geodata-item-etag-value($id)
	return 
			if ($etag-value-to-check = $current-etag)
			then	
				(
					fn:true()
				)
			else
			(
				fn:false()
			)
};
	


(:declare function set-geodata-item-uri( 
	$geodata-item as element(gd:geodata-item)
) as element(gd:geodata-item)
{
   let $id := "urn:cabi.org:id:geodata:" || sem:uuid-string()
   let $uri-node := <gd:uri>{$id}</gd:uri>
   let $updated := if (fn:exists($geodata-item/gd:uri))
                    then
						mem:node-replace($geodata-item/gd:uri, $uri-node)
                    else
						mem:node-insert-child($geodata-item, $uri-node)
   return $updated
};:)

(: Search functions :)

declare function search-geodata-items (
	$terms as xs:string,
	$alias as xs:string
)
{
    let $query :=
        wrap-in-and ((
            if (fn:exists ($terms)) then cts:word-query ($terms) else (),
            if (fn:exists ($alias)) then cts:element-value-query (xs:QName ("gd:alias"), $alias, "exact") else ()
        ))
	return cts:search (fn:collection ($geodata-collection-name), $query)/gd:geodata-item
};

(: ------------------------------------------------------ :)

declare private function wrap-in-and (
    $queries as cts:query*
) as cts:query
{
    if (fn:count ($queries) = 0)
    then cts:and-query(())
    else if (fn:count ($queries) = 1)
    then $queries
    else cts:and-query ($queries)
};