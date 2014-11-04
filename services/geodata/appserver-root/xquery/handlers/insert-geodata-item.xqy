xquery version "1.0-ml";

import module namespace gdlib = "urn:cabi.org:namespace:module:lib:geodata" at "geodata-lib.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace gd = "http://namespaces.cabi.org/namespaces/cabi/geodata";
declare namespace e="http://namespaces.cabi.org/namespaces/errors";

(: ---------------------------------------------------- :)
(:declare variable $geodata-uri-id-name as xs:string := "urn:cabi.org:id:geodata:"; 
$geodata-uri-id-name || sem:uuid-string();:)
declare variable $validation-result as element(gd:geodata-request-validation) := gdlib:validate-geodata-item-for-insert();
declare variable $uri as xs:string := gdlib:generate-new-geodata-item-uri();
declare variable $get-geodata-by-id-service-uri as xs:string := "/geodata/id/" || $uri;

if(xs:boolean($validation-result/@valid))
	then
		(
			(: insert gdlib:insert-geodata-item,  ,$doc-uri)    :)		
			let $geodata-item-to-insert as element(gd:geodata-item) :=  $validation-result/gd:geodata-item
			return	
				gdlib:insert-geodata-item( gdlib:set-document-uri ( $geodata-item-to-insert , $uri), $uri),
				xdmp:set-response-code ( 201 , "Created" ),
				xdmp:add-response-header( "Location", $get-geodata-by-id-service-uri ),
				xdmp:add-response-header( "X-ID", $uri )
		)
	else
		(
			xdmp:set-response-content-type ("application/vnd.cabi.org:errors+xml"),
			xdmp:set-response-code ($validation-result/@response-status-code , $validation-result/@response-status-code-message),
			$validation-result/e:errors
		)