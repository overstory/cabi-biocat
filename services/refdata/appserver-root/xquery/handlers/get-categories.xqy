xquery version "1.0-ml";

declare namespace atom="http://www.w3.org/2005/Atom";

(: ---------------------------------------------------- :)

xdmp:set-response-content-type ("application/atom+xml"),

<atom:feed>
	<atom:id>foobar</atom:id>
	<atom:updated>2014-10-07</atom:updated>
	<atom:link rel="self" href="/refdata/category" type="application/atom+xml"/>
</atom:feed>