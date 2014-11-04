xquery version "1.0-ml";

import module namespace gdlib = "urn:cabi.org:namespace:module:lib:geodata" at "geodata-lib.xqy";

declare namespace gd = "http://namespaces.cabi.org/namespaces/cabi/geodata";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

(: ---------------------------------------------------- :)

declare variable $alias as xs:string? := xdmp:get-request-field ("alias", ());

declare variable $geodata-item as element(gd:geodata-item)? := gdlib:get-geodata-item-by-alias ($alias);

if (fn:exists ($geodata-item))
then 
	if (fn:count($geodata-item)[. eq 1])
		then (
				xdmp:set-response-content-type ("applicaton/vnd.cabi.org:geodata:item+xml"),
				$geodata-item
			 )
		else
		(:not sure that this is needed but added anyway :)
			(
				xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
				xdmp:set-response-code (409 , "Conflict - Alias is not unique"),

				<e:errors>
					<e:resource-not-unique>
						<e:message>There are more than one geodata-items with the alias '{ $alias }'</e:message>
						<e:alias>{ $alias }</e:alias>
					</e:resource-not-unique>
				</e:errors>
			)
else 
	(
		xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
		xdmp:set-response-code (404, "Resource Not Found"),

		<e:errors>
			<e:resource-not-found>
				<e:message>Cannot find GeoData item with alias '{ $alias }'</e:message>
				<e:alias>{ $alias }</e:alias>
			</e:resource-not-found>
		</e:errors>
	)