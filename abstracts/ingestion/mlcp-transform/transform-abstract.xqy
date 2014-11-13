xquery version "1.0-ml";

module namespace xform = "http://cabi.org/transform";

declare namespace cabi = "http://namespaces.cabi.org/namespaces/cabi";

declare variable $style-sheet-path := "/abstract-transform.xsl";
declare variable $uri-prefix := "/abstracts";


declare function transform(
	$content as map:map,
	$context as map:map
) as map:map*
{
	map:put ($content, "value", transform-doc (map:get ($content, "value"))),
	fixup-uri ($content),
	$content
};

(: ---------------------------------------------------- :)

declare private function transform-doc (
	$doc as document-node()
) as document-node()
{
	xdmp:xslt-invoke ($style-sheet-path, $doc)
};

declare private function fixup-uri (
	$content as map:map
) as empty-sequence()
{
	let $uri := map:get ($content, "uri")
	let $doc := map:get ($content, "value")
	let $year := ($doc/cabi:cabi-abstract/cabi:sort-year/fn:string(), "unknown-year")[1]
	let $new-uri := fn:replace ($uri, $uri-prefix, $uri-prefix || "/" || $year)

	return map:put ($content, "uri", $new-uri)
};
