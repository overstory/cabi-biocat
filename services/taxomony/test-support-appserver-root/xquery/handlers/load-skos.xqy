xquery version "1.0-ml";

(:
	DANGER!  This XQuery loads content and overwrites anything that is already present
:)

import module namespace const = "urn:cabi.org:namespace:module:constants" at "constants.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace tax = "http://namespaces.cabi.org/namespaces/cabi/taxonomy";

declare variable $name as xs:string? := xdmp:get-request-field ("name", ());

declare variable $body := rhttp:get-xml-body();

declare function local:insert-skos (
	$item as element()
)
{
	let $doc-uri := "/taxonomy/concepts/" || $name || ".xml"
	return xdmp:document-insert ($doc-uri, $item, xdmp:default-permissions(), ($const:TAXONOMY-COLLECTIONS))
};

local:insert-skos ($body)
,
xdmp:set-response-code (201, "Content Created")

