xquery version "1.0-ml";

declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace rlib = "urn:cabi.org:namespace:module:lib:refdata" at "refdata-lib.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";

(: ---------------------------------------------------- :)

declare variable $id as xs:string? := xdmp:get-request-field ("id", ());
declare variable $word as xs:string? := xdmp:get-request-field ("word", ());
declare variable $qstring as xs:string := if (fn:exists ($word)) then "?word=" || $word else "";

declare variable $items := rlib:get-items-for-category ($id, $word);

<atom:feed>
	<atom:id>foobar</atom:id>
	<atom:updated>{ rhttp:date-as-utc (fn:current-dateTime()) }</atom:updated>
	<atom:title>CABI Refdata Items for category: {$id}</atom:title>
	<atom:link rel="self" href="/refdata/category/id/{ $id }/item{ $qstring }" type="application/atom+xml"/>
	{
		for $item in $items
		return
		<atom:entry>
			<atom:link rel="self" href="/refdata/item/id/{ $item/rd:uri/fn:string() }" type="applicaton/vnd.cabi.org:refdata:item+xml"/>
			<atom:content type="applicaton/vnd.cabi.org:refdata:item+xml">
				{ $item }
			</atom:content>

		</atom:entry>
	}
</atom:feed>

,

xdmp:set-response-content-type ("application/atom+xml")

