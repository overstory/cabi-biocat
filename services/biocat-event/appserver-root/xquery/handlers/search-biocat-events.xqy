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

declare variable $biocat-search-options :=
	<cabi:biocat-search-options>
		<cabi:terms>{ xdmp:get-request-field ("terms", ()) }</cabi:terms>
		<cabi:year>{ xdmp:get-request-field ("year", ()) }</cabi:year>
		<cabi:year-range>{ xdmp:get-request-field ("year-range", ()) }</cabi:year-range>
		<cabi:agent>{ xdmp:get-request-field ("agent", ()) }</cabi:agent>
		<cabi:target>{  xdmp:get-request-field ("target", ()) }</cabi:target>
		<cabi:crop>{ xdmp:get-request-field ("crop", ()) }</cabi:crop>
		<cabi:location-introduced-to>{ xdmp:get-request-field ("location-introduced-to", ()) }</cabi:location-introduced-to>
		<cabi:location-exported-from>{ xdmp:get-request-field ("location-exported-from", ()) }</cabi:location-exported-from>
		<cabi:order>{ xdmp:get-request-field ("order", ()) }</cabi:order>
		<cabi:genus>{ xdmp:get-request-field ("genus", ()) }</cabi:genus>
		<cabi:impact>{ xdmp:get-request-field ("impact", ())}</cabi:impact>
		<cabi:establishment>{ xdmp:get-request-field ("establishment", ()) }</cabi:establishment>
		<cabi:result>{ xdmp:get-request-field ("result", ()) }</cabi:result>
		<cabi:facets>{ xdmp:get-request-field ("facets", ()) }</cabi:facets>
		<cabi:page>{ xs:integer (xdmp:get-request-field ("page", "1")) }</cabi:page>
		<cabi:ipp>{ xs:integer (xdmp:get-request-field ("ipp", "10")) }</cabi:ipp>
	</cabi:biocat-search-options>
;

declare variable $results-page as element(cabi:results-page)? := bclib:search-biocat-event-items (
	$biocat-search-options
);


<atom:feed xmlns="http://www.w3.org/2005/Atom"
    about="urn:cabi.org:search-result:biocat_event_terms=acme"
    xmlns:s="http://ns.cabi.org/namespaces/search">
	<atom:id>{sem:uuid-string()}</atom:id>
	<atom:updated>{ rhttp:date-as-utc (fn:current-dateTime()) }</atom:updated>
	<atom:title>CABI Biocat-event items by search</atom:title>
	
	{
		if (fn:string-length ($results-page/@self-uri/fn:string()) > 0)
		then <atom:link rel="self" href="{ $results-page/@self-uri/fn:string() }" type="application/atom+xml"/>	
		else (),
		if (fn:string-length ($results-page/@next-uri/fn:string()) > 0)
		then <atom:link rel="next" href="{ $results-page/@next-uri/fn:string() }" type="application/atom+xml"/>	
		else (),
		if (fn:string-length ($results-page/@previous-uri/fn:string()) > 0)
		then <atom:link rel="prev" href="{ $results-page/@previous-uri/fn:string() }" type="application/atom+xml"/>	
		else ()	
	}
	<s:results-meta>
		<s:total-hits>{ $results-page/@total/fn:string() }</s:total-hits>
		<s:first-item>{ $results-page/@start/fn:string() }</s:first-item>
		<s:returned-count>{ fn:count($results-page/cabi:bio-event) }</s:returned-count>
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