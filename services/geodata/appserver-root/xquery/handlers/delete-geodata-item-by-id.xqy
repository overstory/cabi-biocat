xquery version "1.0-ml";

import module namespace gdlib = "urn:cabi.org:namespace:module:lib:geodata" at "geodata-lib.xqy";

declare namespace gd = "http://namespaces.cabi.org/namespaces/cabi/geodata";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

(: ---------------------------------------------------- :)

declare variable $id as xs:string? := xdmp:get-request-field ("id", ());
declare variable $etag-value as xs:string := xdmp:get-request-header("etag","");
declare variable $geodata-document-properties as node()? := gdlib:get-geodata-document-properties ($id);
declare variable $geodata-item as element (gd:geodata-item)? :=gdlib:get-geodata-item-by-id ($id);

if (fn:exists($geodata-item))
then
	if (gdlib:etag-matches-current-value($id,$etag-value))
	then (
                xdmp:document-delete(xdmp:node-uri($geodata-item)),
                xdmp:set-response-code (204, "No Content")
	) else (
			let $current-etag-value := gdlib:get-geodata-item-etag-value($id)
			let $given-etag-value := $etag-value
			return	
				(
					xdmp:set-response-code (409, "Conflict"),
					xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
					<e:errors xmlns:e="http://namespaces.cabi.org/namespaces/errors">
						<e:etag-mismatch>
							<e:message>Incorrect ETag value for '{$id}'</e:message>
							<e:current-etag>"{$current-etag-value}"</e:current-etag>
							<e:given-etag>"{$given-etag-value}"</e:given-etag>
						</e:etag-mismatch>
					</e:errors>
				)
			
			
	)
else
(
	xdmp:set-response-code (204, "No Content")
)