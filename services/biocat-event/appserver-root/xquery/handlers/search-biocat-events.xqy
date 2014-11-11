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
		<cabi:page>{ xs:integer (xdmp:get-request-field ("page", "1")) }</cabi:page>
		<cabi:ipp>{ xs:integer (xdmp:get-request-field ("ipp", "10")) }</cabi:ipp>
		<cabi:terms>{ xdmp:get-request-field ("terms", ()) }</cabi:terms>
		<cabi:year-range>{ xdmp:get-request-field ("year-range", ()) }</cabi:year-range>
		{
			for	$year in bclib:tokenise-query-string-values("year") return <cabi:year>{ $year }</cabi:year> ,
			for	$agent in bclib:tokenise-query-string-values("agent") return <cabi:agent>{ $agent }</cabi:agent> ,
			for	$target in bclib:tokenise-query-string-values("target") return <cabi:target>{ $target }</cabi:target> ,
			for	$crop in bclib:tokenise-query-string-values("crop")	return <cabi:crop>{ $crop }</cabi:crop> ,
			for	$location-introduced-to in bclib:tokenise-query-string-values("location-introduced-to") return <cabi:location-introduced-to>{ $location-introduced-to }</cabi:location-introduced-to> ,
			for	$location-exported-from in bclib:tokenise-query-string-values("location-exported-from") return <cabi:location-exported-from>{ $location-exported-from }</cabi:location-exported-from> ,
			for	$order in bclib:tokenise-query-string-values("order") return <cabi:order>{ $order }</cabi:order> ,
			for	$genus in bclib:tokenise-query-string-values("genus") return <cabi:genus>{ $genus }</cabi:genus> ,
			for	$impact in bclib:tokenise-query-string-values("impact") return <cabi:impact>{ $impact }</cabi:impact> ,
			for	$establishment in bclib:tokenise-query-string-values("establishment") return <cabi:establishment>{ $establishment }</cabi:establishment> ,
			for	$result in bclib:tokenise-query-string-values("result") return <cabi:result>{ $result }</cabi:result>
		}
		<cabi:facets>{ xdmp:get-request-field ("facets", "false") }</cabi:facets>
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
		for $link in $results-page/cabi:paging-link
		return <atom:link rel="{ $link/@type }" href="{ $link/@href }" />
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