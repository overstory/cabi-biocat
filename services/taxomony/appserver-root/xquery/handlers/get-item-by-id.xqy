xquery version "1.0-ml";

import module namespace tlib = "urn:cabi.org:namespace:module:lib:taxonomy" at "taxonomy-lib.xqy";

declare namespace tax = "http://namespaces.cabi.org/namespaces/cabi/taxonomy";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

declare variable $id as xs:string? := xdmp:get-request-field ("id", ());

(: ---------------------------------------------------- :)

declare variable $item as element(tax:taxonomy-item)? := tlib:get-item-by-id ($id);

if (fn:exists ($item))
then (
	xdmp:set-response-content-type ("applicaton/vnd.cabi.org:taxonomy:item+xml"),
	$item
) else (
	xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
	xdmp:set-response-code (404, "Resource Not Found"),

	<e:errors>
		<e:resource-not-found>
			<e:message>Cannot find Taxonomy item with ID '{ $id }'</e:message>
			<e:id>{ $id }</e:id>
		</e:resource-not-found>
	</e:errors>
)

