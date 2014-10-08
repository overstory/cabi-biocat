xquery version "1.0-ml";

module namespace rlib = "urn:cabi.org:namespace:module:lib:refdata";

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";

declare variable $refdata-collection-name := "urn:cabi.org:id:collection:refdata";
declare variable $refdata-category-collection-name := "urn:cabi.org:id:collection:refdata:kind:category";

declare function get-all-category-items (
) as element(rd:refdata)*
{
	fn:collection ($refdata-category-collection-name)/rd:refdata
	(: fn:collection ($refdata-collection-name)/rd:refdata[rd:item-type = 'category'] :)
};

declare function get-item-by-id (
	$id as xs:string
) as element(rd:refdata)?
{
	get-item-from-collection ($id, $refdata-collection-name)
};

declare function get-category-item-by-id (
	$id as xs:string
) as element(rd:refdata)?
{
	get-item-from-collection ($id, $refdata-category-collection-name)
};

declare function get-items-for-category (
	$category-id as xs:string,
	$word as xs:string?
) as element(rd:refdata)*
{
	let $category-qname := xs:QName ("rd:category")
	let $query :=
		if (fn:empty ($word))
		then cts:element-value-query ($category-qname, $category-id, "exact")
		else
			cts:and-query ((
				cts:word-query ($word),
				cts:element-value-query ($category-qname, $category-id, "exact")
			))
	return cts:search (fn:collection ($refdata-collection-name), $query)/rd:refdata

	(: fn:collection ($refdata-collection-name)/rd:refdata[rd:category = $category-id] :)
};

(: ------------------------------------------------- :)

declare private function get-item-from-collection (
	$id as xs:string,
	$collection as xs:string
) as element(rd:refdata)?
{
	fn:collection ($collection)/rd:refdata[rd:uri = $id]
};
