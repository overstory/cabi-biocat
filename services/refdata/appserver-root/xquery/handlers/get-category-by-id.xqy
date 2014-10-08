xquery version "1.0-ml";

import module namespace rlib = "urn:cabi.org:namespace:module:lib:refdata" at "refdata-lib.xqy";

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

(: ---------------------------------------------------- :)

declare variable $id as xs:string? := xdmp:get-request-field ("id", ());

declare variable $category as element(rd:refdata)? := rlib:get-category-item-by-id ($id);

if (fn:exists ($category))
then (
	xdmp:set-response-content-type ("applicaton/vnd.cabi.org:refdata:item+xml"),
	$category
) else (
	xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
	xdmp:set-response-code (404, "Resource Not Found"),

	<e:errors>
		<e:resource-not-found>
			<e:message>Cannot find Reference Data category with ID '{ $id }'</e:message>
			<e:id>{ $id }</e:id>
		</e:resource-not-found>
	</e:errors>
)

