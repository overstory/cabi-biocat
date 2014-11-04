xquery version "1.0-ml";

module namespace endpoints="urn:overstory:rest:modules:endpoints";

import module namespace rce="urn:overstory:rest:modules:common:endpoints" at "lib-rest/common-endpoints.xqy";

declare namespace rest="http://marklogic.com/appservices/rest";

(: ---------------------------------------------------------------------- :)

declare private variable $endpoints as element(rest:options) :=
	<options xmlns="http://marklogic.com/appservices/rest">
		<!-- root -->
		<request uri="^(/?)$" endpoint="/xquery/default.xqy" />

		<request uri="^/test-support/clear-db" endpoint="/xquery/handlers/clear-db.xqy">
			<http method="DELETE"/>
		</request>

		<request uri="^/test-support/load-skos/(.+)$" endpoint="/xquery/handlers/load-skos.xqy">
			<uri-param name="name">$1</uri-param>
			<http method="POST"/>
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
