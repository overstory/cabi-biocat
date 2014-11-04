xquery version "1.0-ml";

import module namespace gdlib = "urn:cabi.org:namespace:module:lib:geodata" at "geodata-lib.xqy";

declare namespace gd = "http://namespaces.cabi.org/namespaces/cabi/geodata";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

(: ---------------------------------------------------- :)

declare variable $id as xs:string? := xdmp:get-request-field ("id", ());

declare variable $geodata-item as element(gd:geodata-item)? := gdlib:get-geodata-item-by-id ($id);

if (fn:exists ($geodata-item))
then (
	xdmp:set-response-content-type ("application/vnd.cabi.org:geodata:item+xml"),
	$geodata-item
) else (
	xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
	xdmp:set-response-code (404, "Resource Not Found"),

	<e:errors>
		<e:resource-not-found>
			<e:message>Cannot find GeoData item with ID '{ $id }'</e:message>
			<e:id>{ $id }</e:id>
		</e:resource-not-found>
	</e:errors>
)
