xquery version "1.0-ml";

module namespace endpoints="urn:overstory:rest:modules:endpoints";

import module namespace rce="urn:overstory:rest:modules:common:endpoints" at "lib-rest/common-endpoints.xqy";

declare namespace rest="http://marklogic.com/appservices/rest";

(: ---------------------------------------------------------------------- :)

declare private variable $endpoints as element(rest:options) :=
	<options xmlns="http://marklogic.com/appservices/rest">
		<!-- root -->
		<request uri="^(/?)$" endpoint="/xquery/default.xqy" />

		<!-- Place matchers here to math URL patterns and invoke XQuery mpdules -->
		<!-- See the docs at https://github.com/marklogic/ml-rest-lib for details -->
		<request uri="^/blah/foo/(.+)$" endpoint="/xquery/handlers/foobar.xqy">
			<uri-param name="id">$1</uri-param>
		</request>

		<!-- ================================================================= -->

		<request uri="^/refdata/category$" endpoint="/xquery/handlers/get-categories.xqy"  user-params="deny">
		</request>

		<request uri="^/refdata/category/id/(.*)$" endpoint="/xquery/handlers/get-category-by-id.xqy"  user-params="deny">
			<uri-param name="id">$1</uri-param>
		</request>

		<request uri="^/refdata/item/id/(.*)$" endpoint="/xquery/handlers/get-item-by-id.xqy"  user-params="deny">
			<uri-param name="id">$1</uri-param>
		</request>

		<!-- ================================================================= -->

		{ $rce:DEFAULT-ENDPOINTS }
	</options>;

(: ---------------------------------------------------------------------- :)

declare function endpoints:options (
) as element(rest:options)
{
	$endpoints
};
