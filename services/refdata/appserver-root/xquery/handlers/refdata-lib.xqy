xquery version "1.0-ml";

module namespace rlib = "urn:cabi.org:namespace:module:lib:refdata";

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";

declare function get-all-category-items (
) as element(rd:refdata)*
{
	fn:doc()/element(rd:refdata)
};