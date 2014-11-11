xquery version "1.0-ml";
module namespace bclib = "urn:cabi.org:namespace:module:lib:biocat";

import module namespace mem = "http://xqdev.com/in-mem-update" at '/MarkLogic/appservices/utils/in-mem-update.xqy';

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";
declare namespace cabi = "http://namespaces.cabi.org/namespaces/cabi";
declare namespace biol = "http://ontologi.es/biol/ns";
declare namespace dcterms = "http://purl.org/dc/terms";
declare namespace atom = "http://www.w3.org/2005/Atom";

declare variable $biocat-collection-name := "urn:cabi.org:id:collection:biocat:event";

declare variable $BIOCAT-COLLECTIONS := ($biocat-collection-name);

declare private variable $BIOCAT-QUERY-PARAMETERS-TOKENISE-REGEX := "[, ]+";

(: ------------------------------------------------- :)

(: Public functions :)


declare function get-biocat-event-by-id (
	$id as xs:string
) as element(cabi:bio-event)?
{
	fn:collection ($biocat-collection-name)/cabi:bio-event[cabi:uri/text() = $id]
};


(:terms,agent,target,location-introduced-to, location-exported-from,establishment,impact,result,crop,genus :)
(:biocat{?,year,year-range,,,,,,,,page,ipp,facets}:)


declare function search-biocat-event-items (
	$search-options as element(cabi:biocat-search-options)
) as element(cabi:results-page)?
{

	let $year-range as xs:string? := if (fn:exists ($search-options/cabi:year-range)) then $search-options/cabi:year-range else ()
	let $start-end-years := fn:tokenize ($year-range, "-") ! xs:gYear(.)
	let $start-year := if ((fn:count ($start-end-years) > 1) or fn:not(fn:starts-with ($year-range, "-"))) then $start-end-years[1] else ()
	let $end-year := if (fn:count ($start-end-years) > 1) then $start-end-years[2] else if (fn:not (fn:ends-with ($year-range, "-"))) then $start-end-years[1] else ()
	
	let $page as xs:integer := if (fn:exists ($search-options/cabi:page)) then xs:integer ($search-options/cabi:page) else xs:integer("1")
	let $ipp as xs:integer := if (fn:exists ($search-options/cabi:ipp)) then xs:integer ($search-options/cabi:ipp) else xs:integer("10")
	
	let $start-item as xs:integer := (($page - 1) * $ipp) + 1
	let $end-item as xs:integer := ($start-item + $ipp) - 1
	
	
    let $query :=
        wrap-in-and ((
			terms-query($search-options/cabi:terms),
			year-query($search-options/cabi:year),   (: function mapping here, will suppress call if $year == () :) 
			year-range-query($start-year, $end-year),
            agent-query($search-options/cabi:agent),
            target-query($search-options/cabi:target),
			crop-query($search-options/cabi:crop),
			location-introduced-to-query($search-options/cabi:location-introduced-to),
			location-exported-from-query($search-options/cabi:location-exported-from),
			genus-query($search-options/cabi:genus),
			order-query($search-options/cabi:order),
			establishment-query($search-options/cabi:establishment),
			impact-query($search-options/cabi:impact),
			result-query($search-options/cabi:result)
        ))

(:
	let $total		:= xdmp:estimate(cts:search (fn:collection ($BIOCAT-COLLECTIONS), $query))
:)
	let $total := fn:count (cts:search (fn:collection ($BIOCAT-COLLECTIONS), $query))
	let $results	:= cts:search (fn:collection ($BIOCAT-COLLECTIONS), $query)[$start-item to $end-item]
	let $start-item := if ($start-item > $total) then 0 else $start-item
	(: Get query string preparation values :)
	let $query-string-values := bclib:create-query-string-parameters($search-options)
	let $query-string-without-paging := "?" || fn:string-join ($query-string-values, "&amp;")
	let $self-uri := if ($start-item >= 1) 
					 then	"biocat" || $query-string-without-paging || "&amp;page=" || $page
					 else ()
	let $next-uri := if ($total > $end-item)
					 then	"biocat" || $query-string-without-paging || "&amp;page=" || $page + 1
					 else ()
	let $previous-uri := if ($start-item > 1) 
					 then	"biocat" || $query-string-without-paging || "&amp;page=" || $page - 1 
					 else ()

	return 
		<cabi:results-page 
			start="{ $start-item }" 
			total="{ $total }">
			{
				create-paging-link("self",$self-uri),
				create-paging-link("next",$next-uri),
				create-paging-link("prev",$previous-uri)
			}
			{ 
				$results/cabi:bio-event 
			}
		</cabi:results-page>
};

declare function tokenise-query-string-values(
	$query-string-parameter-name as xs:string
) as xs:string*
{
	fn:tokenize(xdmp:get-request-field ($query-string-parameter-name,()), $BIOCAT-QUERY-PARAMETERS-TOKENISE-REGEX)	
};

declare private function create-paging-link(
	$link-type as xs:string,
	$link as xs:string?
) as element(cabi:paging-link)?
{
	if (fn:empty($link))
	then () 
	else <cabi:paging-link type="{ $link-type }" href="{ $link }" />  
};

(: PRIVATE FUNCTIONS :)

declare private function create-query-string-parameters(
	$search-options as element(cabi:biocat-search-options)
) as xs:string*
{
	
	for $search-option in $search-options/*[not(self::cabi:page)]
	let $query-string-parameters as xs:string? := 	
		if (fn:string-length ($search-option/fn:string ()) > 0) 
		then (fn:local-name ($search-option) || "=" || $search-option/fn:string())  
		else ()
	return $query-string-parameters
};

(: Query building functions :)
declare private function agent-query (
	$agent as xs:string*
) as cts:query?
{
	if (fn:empty($agent))
	then ()
	else cts:element-query (xs:QName ("cabi:agent"), cts:element-value-query (xs:QName ("cabi:organism-uri"), $agent, "exact"))
};

declare private function crop-query(
	$crop as xs:string*
) as cts:query?
{
	if (fn:empty($crop))
	then ()
	else cts:element-value-query(xs:QName("cabi:crop"), $crop,"exact")
};

declare private function establishment-query(
	$establishment as xs:string*
) as cts:query?
{
	if (fn:empty($establishment))
	then ()
	else cts:element-value-query(xs:QName("cabi:establishment"), $establishment,"exact")	
};

declare private function genus-query(
	$genus as xs:string*
) as cts:query?
{
	if (fn:empty ($genus))
	then ()
	else cts:element-value-query (xs:QName ("biol:genus"), $genus, "case-insensitive")
};

declare private function impact-query(
	$impact as xs:string*
) as cts:query?
{
	if (fn:empty ($impact)) 
	then ()
	else cts:element-query (xs:QName ("cabi:outcome"), cts:element-value-query (xs:QName ("cabi:impact"), $impact, "exact"))
};

declare private function location-exported-from-query(
	$location-exported-from as xs:string*
) as cts:query?
{
	if (fn:empty ($location-exported-from)) 
	then ()
	else 
		let $exported-from-qname := xs:QName ("cabi:exported-from")
		let $country-uri-qname := xs:QName ("cabi:country")
		let $bio-geographic-range-uri-qname := xs:QName ("cabi:bio-geographic-range-uri")
		let $country-region-uri-qname := xs:QName ("cabi:country-region")
		return cts:element-query(
								$exported-from-qname,
								wrap-in-or (	
												(
													cts:element-value-query ($country-uri-qname, $location-exported-from, "exact"),
													cts:element-value-query ($bio-geographic-range-uri-qname, $location-exported-from, "exact"),
													cts:element-value-query ($country-region-uri-qname, $location-exported-from, "exact")					
												)
											)
							)
};

declare private function location-introduced-to-query(
	$location-introduced-to as xs:string*
) as cts:query?
{
	if (fn:empty ($location-introduced-to)) 
	then ()
	else 
		let $introduced-to-qname := xs:QName ("cabi:introduced-to")
		let $country-uri-qname := xs:QName ("cabi:country")
		let $bio-geographic-range-uri-qname := xs:QName ("cabi:bio-geographic-range-uri")
		let $country-region-uri-qname := xs:QName ("cabi:country-region")
		return cts:element-query(
								$introduced-to-qname,
								wrap-in-or (	
												(
													cts:element-value-query ($country-uri-qname, $location-introduced-to, "exact"),
													cts:element-value-query ($bio-geographic-range-uri-qname, $location-introduced-to, "exact"),
													cts:element-value-query ($country-region-uri-qname, $location-introduced-to, "exact")					
												)
											)
							)
};

declare private function order-query(
	$order as xs:string*
) as cts:query?
{
	if (fn:empty($order))
	then ()
	else cts:element-value-query (xs:QName ("biol:order"), $order, "case-insensitive")
};

declare private function result-query(
	$result as xs:string*
) as cts:query?
{
	if (fn:empty ($result)) 
	then ()
	else cts:element-value-query (xs:QName ("cabi:result"), $result, "exact")
};

declare private function target-query(
	$target as xs:string*
) as cts:query?
{
	if (fn:empty ($target)) 
	then ()
	else cts:element-query (xs:QName ("cabi:target"), cts:element-value-query (xs:QName ("cabi:organism-uri"), $target, "exact"))
};

declare private function terms-query(
	$terms as xs:string?
) as cts:query?
{
	if (fn:empty($terms))
	then ()
	else cts:word-query (fn:tokenize ($terms, "[,;:| \t]+")) 
};



(: ------------------------------------------------------ :)

declare private function wrap-in-or (
    $queries as cts:query*
) as cts:query
{
    if (fn:count ($queries) = 0)
    then cts:or-query(())
    else if (fn:count ($queries) = 1)
    then $queries
    else cts:or-query ($queries)
};

declare private function wrap-in-and (
    $queries as cts:query*
) as cts:query
{
    if (fn:count ($queries) = 0)
    then cts:and-query(())
    else if (fn:count ($queries) = 1)
    then $queries
    else cts:and-query ($queries)
};


(:------------------------------------------------------:)
declare private function year-range-query(
	$target-start-year as xs:gYear?,
	$target-end-year as xs:gYear?
) as cts:query?
{
	if (fn:empty (($target-start-year, $target-end-year)))
	then ()
	else
	let $target-start-year := ($target-start-year, xs:gYear ("0001"))[1]
	let $target-end-year := ($target-end-year, xs:gYear ("9999"))[1]
	let $dates-qname := xs:QName ("cabi:dates")
	let $start-year-qname := xs:QName ("cabi:start-year")
	let $end-year-qname := xs:QName ("cabi:end-year")
	let $first-release-qname := xs:QName ("cabi:first-release")
	
	(: query range :)
	return
		cts:element-query (xs:QName ("cabi:report-range"),
			wrap-in-and((
				if (fn:exists ($target-start-year)) then cts:element-range-query (($end-year-qname), ">=", xs:date ($target-start-year || "-01-01")) else (),
				if (fn:exists ($target-end-year)) then cts:element-range-query (($start-year-qname), "<=", xs:date($target-end-year || "-12-31")) else ()
			))
		)
};

declare function year-query (
	$year as xs:string?
) as cts:query?
{
	(:if (fn:string-length ($year) > 0) :)
	if (fn:not(fn:empty ($year)))
	then
		let $year-queries :=
			let $first-release-qname := xs:QName("cabi:first-release")
			let $year-reported-qname := xs:QName("cabi:year-reported")
			for $year-value in fn:tokenize($year,"[, ]+")
			return
				if (fn:not(fn:empty($year-value)) and ($year-value castable as xs:gYear))
				then 
					(wrap-in-and((
							cts:element-range-query ($first-release-qname,">=", xs:date ($year || "-01-01")),
							cts:element-range-query ($first-release-qname,"<=", xs:date ($year || "-12-31"))
						)),
						cts:element-value-query ($year-reported-qname, $year))
				else ()
		return 	if (fn:empty($year-queries))
				then ()
				else wrap-in-or($year-queries)	
	else
		()
};