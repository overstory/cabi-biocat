xquery version "1.0-ml";

declare namespace e="http://namespaces.cabi.org/namespaces/errors";

declare variable $id as xs:string? := xdmp:get-request-field ("id", ());

(: ---------------------------------------------------- :)

xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
xdmp:set-response-code (404, "Resource Not Found"),

<e:errors>
	<e:resource-not-found>
		<e:message>Cannot find Reference Data category with ID '{ $id }'</e:message>
		<e:id>{ $id }</e:id>
	</e:resource-not-found>
</e:errors>