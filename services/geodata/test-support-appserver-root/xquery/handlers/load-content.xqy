xquery version "1.0-ml";

(:
	DANGER!  This XQuery loads content and overwrites anything that is already present
:)

import module namespace const = "urn:cabi.org:namespace:module:constants" at "constants.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace gd = "http://namespaces.cabi.org/namespaces/cabi/geodata";

declare variable $body := rhttp:get-xml-body();

declare function local:insert-geodata (
	$item as element()
)
{
	let $doc-uri := "/geodata/item/" || fn:string ($item/gd:uri) || ".xml"
	return xdmp:document-insert ($doc-uri, $item, xdmp:default-permissions(),
		($const:GEODATA-COLLECTIONS))
};

if ($body instance of element(container))
then for $item in $body/* return local:insert-geodata ($item)
else local:insert-geodata ($body)
,
xdmp:set-response-code (201, "Content Created")