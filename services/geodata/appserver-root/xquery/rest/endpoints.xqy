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
		<request uri="^/geodata/id/(.+)$" endpoint="/xquery/handlers/get-geodata-by-id.xqy">
			<uri-param name="id">$1</uri-param>
		</request>
		
		<request uri="^/geodata/alias/(.+)$" endpoint="/xquery/handlers/get-geodata-by-alias.xqy" user-params="deny">
			<uri-param name="alias">$1</uri-param>
		</request>
		
		<request uri="^/geodata$" endpoint="/xquery/handlers/insert-geodata-item.xqy" user-params="deny">
			<http method="POST"/>
		</request>
		
		<request uri="^/geodata/id/(.+)$" endpoint="/xquery/handlers/delete-geodata-item-by-id.xqy" user-params="deny">
			<http method="DELETE"/>
			<uri-param name="id">$1</uri-param>
		</request>
		
		<request uri="^/geodata/id/(.+)$" endpoint="/xquery/handlers/update-geodata-item-by-id.xqy" user-params="deny">
			<http method="PUT"/>
			<uri-param name="id">$1</uri-param>
		</request>
		<request uri="^/geodata$" endpoint="/xquery/handlers/search-geodata-items" user-params="allow">
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
