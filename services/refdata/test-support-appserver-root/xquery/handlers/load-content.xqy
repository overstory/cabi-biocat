xquery version "1.0-ml";

(:
	DANGER!  This XQuery loads content and overwrites anything that is already present
:)

import module namespace const = "urn:cabi.org:namespace:module:constants" at "constants.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";

declare variable $body := rhttp:get-xml-body();

declare function local:insert-refdata (
	$item as element()
)
{
	let $doc-uri := "/refdata/item/" || fn:string ($item/rd:uri) || ".xml"
	return xdmp:document-insert ($doc-uri, $item, xdmp:default-permissions(),
		($const:REFDATA-COLLECTIONS, $const:type-collection-name-root || $item/rd:item-type/fn:string()))
};

if ($body instance of element(container))
then for $item in $body/* return local:insert-refdata ($item)
else local:insert-refdata ($body)
,
xdmp:set-response-code (201, "Content Created")

