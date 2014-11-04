xquery version "1.0-ml";

import module namespace gdlib = "urn:cabi.org:namespace:module:lib:geodata" at "geodata-lib.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace gd = "http://namespaces.cabi.org/namespaces/cabi/geodata";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

(: ---------------------------------------------------- :)

declare variable $id as xs:string? := xdmp:get-request-field ("id", ());
declare variable $etag-value as xs:string? := xdmp:get-request-header("etag","");
declare variable $validation-result as element(gd:geodata-request-validation) := gdlib:validate-geodata-item-for-update($id,$etag-value);

if (xs:boolean($validation-result/@valid))
then
	(
		let $geodata-item as element (gd:geodata-item) := $validation-result/gd:geodata-item
		let $document-uri :=$validation-result/@document-uri
		let $new-etag-value := gdlib:update-geodata-item($geodata-item,$id,$document-uri)
		return	
			(
				xdmp:add-response-header("etag",$new-etag-value),
				xdmp:set-response-code (201, "Created")
			)
	)
else
	(
		xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
		xdmp:set-response-code ($validation-result/@response-status-code , $validation-result/@response-status-code-message),
		$validation-result/e:errors
	)