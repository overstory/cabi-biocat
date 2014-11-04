xquery version "1.0-ml";

import module namespace gdlib = "urn:cabi.org:namespace:module:lib:geodata" at "geodata-lib.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace gd = "http://namespaces.cabi.org/namespaces/cabi/geodata";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

(: ---------------------------------------------------- :)

declare variable $terms as xs:string? := xdmp:get-request-field ("terms", ());
declare variable $alias as xs:string? := xdmp:get-request-field ("alias", ());

declare variable $query-string as xs:string := if (fn:exists($terms) or fn:exists($alias))
												then
													"?terms=" || $terms || "&alias=" || $alias
												else
													""
													


declare variable $geodata-items as element(gd:geodata-item)* := gdlib:search-geodata-items ($terms, $alias);

<atom:feed>
	<atom:id>{sem:uuid-string()}</atom:id>
	<atom:updated>{ rhttp:date-as-utc (fn:current-dateTime()) }</atom:updated>
	<atom:title>CABI Geodata items by search</atom:title>
	<atom:link rel="self" href="/geodata{ $query-string }" type="application/atom+xml"/>
	{
		for $item in $geodata-items
		return
		<atom:entry>
			<atom:link rel="self" href="/geodata/id/{ $item/gd:uri/fn:string() }" type="applicaton/vnd.cabi.org:geodata:item+xml"/>
			<atom:content type="applicaton/vnd.cabi.org:geodata:item+xml">
				{ $item }
			</atom:content>

		</atom:entry>
	}
</atom:feed>

,

xdmp:set-response-content-type ("application/atom+xml")