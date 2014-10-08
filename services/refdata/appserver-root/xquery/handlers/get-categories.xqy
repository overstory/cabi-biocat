xquery version "1.0-ml";

declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace rlib = "urn:cabi.org:namespace:module:lib:refdata" at "refdata-lib.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";

(: ---------------------------------------------------- :)

declare variable $categories := rlib:get-all-category-items();

<atom:feed>
	<atom:id>foobar</atom:id>
	<atom:updated>{ rhttp:date-as-utc (fn:current-dateTime()) }</atom:updated>
	<atom:title>CABI Refdata Categories</atom:title>
	<atom:link rel="self" href="/refdata/category" type="application/atom+xml"/>
	{
		for $category in $categories
		return
		<atom:entry>
			<atom:link rel="self" href="/refdata/category/id/{ $category/rd:uri/fn:string() }" type="applicaton/vnd.cabi.org:refdata:item+xml"/>
			<atom:content type="applicaton/vnd.cabi.org:refdata:item+xml">
				{ $category }
			</atom:content>

		</atom:entry>
	}
</atom:feed>

,

xdmp:set-response-content-type ("application/atom+xml")

