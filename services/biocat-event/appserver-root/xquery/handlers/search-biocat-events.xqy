xquery version "1.0-ml";

import module namespace bclib = "urn:cabi.org:namespace:module:lib:biocat" at "biocat-lib.xqy";
import module namespace rhttp = "urn:overstory:rest:modules:rest:http" at "../rest/lib-rest/http.xqy";

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";
declare namespace cabi = "http://namespaces.cabi.org/namespaces/cabi";
declare namespace biol = "http://ontologi.es/biol/ns";
declare namespace dcterms = "http://purl.org/dc/terms";
declare namespace atom = "http://www.w3.org/2005/Atom";
(: ---------------------------------------------------- :)
(:biocat{?terms,year,year-range,agent,target,crop,location,genus,order,establishment,impact,result,page,ipp,facets}:)
declare variable $terms as xs:string? := xdmp:get-request-field ("terms", ());
declare variable $year as xs:string? := xdmp:get-request-field ("year", ());
(:declare variable $year as xs:int?,:)
declare variable $year-range as xs:string? := xdmp:get-request-field ("year-range", ());
declare variable $agent as xs:string? := xdmp:get-request-field ("agent", ());
declare variable $target as xs:string? := xdmp:get-request-field ("target", ());
declare variable $crop as xs:string? := xdmp:get-request-field ("crop", ());
declare variable $location-introduced-to as xs:string? := xdmp:get-request-field ("location-introduced-to", ());
declare variable $location-exported-from as xs:string? := xdmp:get-request-field ("location-exported-from", ());
declare variable $genus as xs:string? := xdmp:get-request-field ("genus", ());
declare variable $order as xs:string? := xdmp:get-request-field ("order", ());
declare variable $establishment as xs:string?:= xdmp:get-request-field ("establishment", ());
declare variable $impact as xs:string? := xdmp:get-request-field ("impact", ());
declare variable $result as xs:string? := xdmp:get-request-field ("result", ());
declare variable $page-request-value as xs:string? := xdmp:get-request-field ("page", ());
declare variable $ipp-request-value as xs:string?:= xdmp:get-request-field ("ipp", ());
declare variable $facets as xs:string? := xdmp:get-request-field ("facets", ());

declare variable $page as xs:int := if (fn:exists($page-request-value)) then xs:int($page-request-value) else 1;
declare variable $ipp as xs:int := if (fn:exists($ipp-request-value)) then xs:int($ipp-request-value) else 10;

declare variable $query-string-values as xs:string :=  fn:string(if (fn:exists($terms))		then "terms=" 			|| $terms || "&#38;"	else "") ||
													   fn:string(if (fn:exists($year))		then "year="			|| $year || "&#38;"		else "")  ||
													   fn:string(if (fn:exists($year-range))	then "year-range=" 	|| $year-range || "&#38;" else "") ||
													   fn:string(if (fn:exists($agent))		then "agent=" 			|| $agent || "&#38;" else "") ||
													   fn:string(if (fn:exists($target))		then "target=" 		|| $target || "&#38;" else "") ||
													   fn:string(if (fn:exists($crop))		then "crop=" 			|| $crop || "&#38;" else "") ||
													   fn:string(if (fn:exists($location-introduced-to)) then "location-introduced-to=" || $location-introduced-to || "&#38;" else "") ||
													   fn:string(if (fn:exists($location-exported-from)) then "location-exported-from=" || $location-exported-from || "&#38;" else "") ||
													   fn:string(if (fn:exists($genus))		then "genus=" 			|| $genus || "&#38;" else "") ||
													   fn:string(if (fn:exists($impact))		then "impact=" 		|| $impact || "&#38;" else "") ||
													   fn:string(if (fn:exists($establishment)) then "establishment=" || $establishment || "&#38;" else "") ||
													   fn:string(if (fn:exists($impact))		then "impact=" 		|| $impact || "&#38;"  else "") ||
													   fn:string(if (fn:exists($result))		then "result=" 		|| $result || "&#38;" else "") ||
													   fn:string(if (fn:exists($page))		then "page=" 			|| fn:string($page) || "&#38;" else "") ||
													   fn:string(if (fn:exists($ipp))			then "ipp=" 		|| fn:string($ipp) || "&#38;" else "") ||
													   fn:string(if (fn:exists($facets))		then "facets=" 		|| $facets else "");

declare variable $query-string as xs:string := if (fn:string-length($query-string-values) > 0) then "?" || $query-string-values else "";

declare variable $results-page as element(cabi:results-page)? := bclib:search-biocat-event-items (
	$terms,
	$year,
	$year-range,
	$agent,
	$target,
	$crop,
	$location-introduced-to,
	$location-exported-from,
	$genus,
	$order,
	$establishment,
	$impact,
	$result,
	$page,
	$ipp,
	$facets	
);

<atom:feed xmlns="http://www.w3.org/2005/Atom"
    about="urn:cabi.org:search-result:biocat_event_terms=acme"
    xmlns:s="http://ns.cabi.org/namespaces/search">
	<atom:id>{sem:uuid-string()}</atom:id>
	<atom:updated>{ rhttp:date-as-utc (fn:current-dateTime()) }</atom:updated>
	<atom:title>CABI Biocat-event items by search</atom:title>
	<atom:link rel="self" href="/biocat{ $query-string }" type="application/atom+xml"/>
	<s:results-meta>
		<s:total-hits>{ fn:string($results-page/@total) }</s:total-hits>
		<s:first-item>{ fn:string($results-page/@start) }</s:first-item>
		<s:returned-count>{ fn:string(fn:count($results-page/cabi:bio-event)) }</s:returned-count>
	</s:results-meta>
	{
		for $item in $results-page/cabi:bio-event
		return
		<atom:entry>
			<atom:link rel="self" href="/biocat/id/{ $item/cabi:uri/fn:string() }" type="applicaton/vnd.cabi.org:biocat-event:item+xml"/>
			<atom:content type="applicaton/vnd.cabi.org:biocat-event:item+xml">
				{ $item }
			</atom:content>
		</atom:entry>
	}
</atom:feed>

,

xdmp:set-response-content-type ("application/atom+xml")