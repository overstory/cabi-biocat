xquery version "1.0-ml";

import module namespace bclib = "urn:cabi.org:namespace:module:lib:biocat" at "biocat-lib.xqy";

declare namespace cabi = "http://namespaces.cabi.org/namespaces/cabi";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

(: ---------------------------------------------------- :)

declare variable $id as xs:string? := xdmp:get-request-field ("id", ());

declare variable $bio-event as element(cabi:bio-event)? := bclib:get-biocat-event-by-id ($id);

if (fn:exists ($bio-event))
then (
	xdmp:set-response-content-type ("application/vnd.cabi.org:biocat:event+xml"),
	$bio-event
) else (
	xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
	xdmp:set-response-code (404, "Resource Not Found"),

	<e:errors>
		<e:resource-not-found>
			<e:message>Cannot find Biocat event with ID '{ $id }'</e:message>
			<e:id>{ $id }</e:id>
		</e:resource-not-found>
	</e:errors>
)
