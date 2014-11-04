xquery version "1.0-ml";
module namespace bclib = "urn:cabi.org:namespace:module:lib:biocat";

import module namespace mem = "http://xqdev.com/in-mem-update" at '/MarkLogic/appservices/utils/in-mem-update.xqy';

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";
declare namespace cabi = "http://namespaces.cabi.org/namespaces/cabi";
declare namespace biol = "http://ontologi.es/biol/ns";
declare namespace dcterms = "http://purl.org/dc/terms";

declare variable $biocat-collection-name := "urn:cabi.org:id:collection:biocat:event";

declare variable $BIOCAT-COLLECTIONS := ($biocat-collection-name);

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
	$terms as xs:string?,
	$year as xs:string?,
	$year-range as xs:string?,
	$agent as xs:string?,
	$target as xs:string?,
	$crop as xs:string?,
	$location-introduced-to as xs:string?,
	$location-exported-from as xs:string?,
	$genus as xs:string?,
	$order as xs:string?,
	$establishment as xs:string?,
	$impact as xs:string?,
	$result as xs:string?,
	$page as xs:int,
	$ipp as xs:int,
	$facets as xs:string?	
)
 as element(cabi:results-page)?
{
	let $start-item as xs:int := (($page - 1) * $ipp) + 1
	let $end-item as xs:int := ($start-item + $ipp) - 1
    let $query :=
        wrap-in-and ((
			if (fn:exists($terms))
				then wrap-in-or(
							(cts:word-query ($terms),
							 cts:element-attribute-word-query(
								xs:QName("cabi:country"),
								xs:QName("name"),
								$terms,
								("case-insensitive","diacritic-insensitive","stemmed","punctuation-insensitive")
							 )
							)
						)
				else (),
			if (fn:exists($year))
				then
					wrap-in-or(
						for $year-value in fn:tokenize($year,",")
						return if (fn:string-length($year-value) = 4) then get-year-query($year-value) else ()
					)
				else (),
			if (fn:exists($year-range))
				then
					wrap-in-or(
						let $year-values := get-individual-years-from-range($year-range)
						return get-year-range-query(
								(if (fn:string-length($year-values[1]) > 0) then $year-values[1] else ()),
								(if (fn:string-length($year-values[2]) > 0) then $year-values[2] else ())
							)
					)
				else (),
            if (fn:exists ($agent)) 
				then
					wrap-in-or(
						for $agent-uri-value in fn:tokenize($agent,",")
						return get-agent-query($agent-uri-value)
					)
				else (),
            if (fn:exists ($target)) 
				then
					wrap-in-or(
						for $target-uri-value in fn:tokenize($target,",")
						return get-target-query($target-uri-value)
					)
				else (),
			 if (fn:exists ($crop)) 
				then get-crop-query($crop)
				else (),
			if (fn:exists ($location-introduced-to)) 
				then
					wrap-in-or(
						for $location-introduced-to-uri-value in fn:tokenize($location-introduced-to,",")
						return get-location-introduced-to-query($location-introduced-to-uri-value)
					)
				else (),
			if (fn:exists ($location-exported-from)) 
				then
					wrap-in-or(
						for $location-exported-from-uri-value in fn:tokenize($location-exported-from,",")
						return  get-location-exported-from-query($location-exported-from-uri-value)
					)
				else (),
			if (fn:exists($genus))
				then get-genus-query ($genus)
				else (),
			if (fn:exists($order))
				then get-order-query ($order)
				else (),	
			if (fn:exists ($establishment)) 
				then
					wrap-in-or(
						for $establishment-uri-value in fn:tokenize($establishment,",")
						return  get-establishment-query($establishment-uri-value)
					)
				else (),
			if (fn:exists ($impact)) 
				then
					wrap-in-or(
						for $impact-uri-value in fn:tokenize($impact,",")
						return  get-impact-query($impact-uri-value)
					)
				else (),
			if (fn:exists ($result)) 
				then
					wrap-in-or(
						for $result-uri-value in fn:tokenize($result,",")
						return  get-result-query($result-uri-value)
					)
				else ()
        ))

	let $total		:= xdmp:estimate(cts:search (fn:collection ($BIOCAT-COLLECTIONS), $query))
	let $results	:= cts:search (fn:collection ($BIOCAT-COLLECTIONS), $query)[$start-item to $end-item]

	return element cabi:results-page {
		attribute start { if ($start-item > $total) then 0 else $start-item },
		attribute total { $total },
		$results/cabi:bio-event
	}
};


(: PRIVATE FUNCTIONS :)

declare private function get-individual-years-from-range(
	$year-range as xs:string
)
{
	let $year-values := fn:tokenize($year-range,"-")
	return if (fn:count($year-values) = 0) then ()
			else if (fn:count($year-values) <= 2) then $year-values
			else $year-values[1 to 2]
};

declare private function get-year-range-query(
	$start-year as xs:string?,
	$end-year as xs:string?
)
{
	let $dates-qname := xs:QName("cabi:dates")
	let $start-year-qname := xs:QName("cabi:start-year")
	let $end-year-qname := xs:QName("cabi:end-year")
	let $first-release-qname := xs:QName("cabi:first-release")
	return cts:element-query($dates-qname,
				wrap-in-or(
					(: query range :)
					(
						wrap-in-and(
							(if (fn:exists($start-year)) then cts:element-range-query($start-year-qname,">=", xs:date($start-year || "-01-01")) else (),
							if (fn:exists($end-year)) then cts:element-range-query($end-year-qname,"<=", xs:date($end-year || "-01-01")) else ())
						),
						wrap-in-and(
							(if (fn:exists($start-year)) then cts:element-range-query($first-release-qname,">=", xs:date($start-year || "-01-01")) else (),
							if (fn:exists($end-year)) then cts:element-range-query($first-release-qname,"<=", xs:date($end-year || "-01-01")) else ())
						)
					)
				)
			)
	
};

declare private function get-year-query(
	$year as xs:string
)
{
	let $dates-qname := xs:QName("cabi:dates")
	let $first-release-qname := xs:QName("cabi:first-release")
	let $year-reported-qname := xs:QName("cabi:year-reported")
	return cts:element-query($dates-qname,
				wrap-in-or(
							( 
								wrap-in-and(
									(
										cts:element-range-query($first-release-qname,">=",xs:date($year || "-01-01")),
										cts:element-range-query($first-release-qname,"<=",xs:date($year || "-12-31"))
									 )
								),
								wrap-in-and(
									(
										cts:element-value-query($year-reported-qname,$year || "-??-??")
									 )
								)	
							 )
						   )
				)
};


declare private function get-genus-query(
	$genus as xs:string
)
{
	let $organism-qname := xs:QName("cabi:organism")
	let $genus-qname := xs:QName("biol:genus")
	return cts:element-query($organism-qname,cts:element-value-query($genus-qname, $genus,("stemmed","case-insensitive")))
};

declare private function get-order-query(
	$order as xs:string
)
{
	let $organism-qname := xs:QName("cabi:organism")
	let $order-qname := xs:QName("biol:order")
	return cts:element-query($organism-qname,cts:element-value-query($order-qname, $order,("stemmed","case-insensitive")))
};

declare private function get-crop-query(
	$crop as xs:string
)
{
	let $threaten-species-qname := xs:QName("cabi:threatened-species")
	let $crop-qname := xs:QName("cabi:crop")
	return cts:element-query($threaten-species-qname,cts:element-value-query($crop-qname, $crop,("stemmed","case-insensitive")))
};


declare private function get-agent-query(
	$agent-uri as xs:string
)
{
	let $agent-qname := xs:QName("cabi:agent")
	let $organism-uri-qname := xs:QName("cabi:organism-uri")
	return cts:element-query($agent-qname,cts:element-value-query($organism-uri-qname, $agent-uri,"exact"))
};

declare private function get-target-query(
	$target-uri as xs:string
)
{
	let $target-qname := xs:QName("cabi:target")
	let $organism-uri-qname := xs:QName("cabi:organism-uri")
	return cts:element-query($target-qname,cts:element-value-query($organism-uri-qname, $target-uri,"exact"))
};

declare private function get-establishment-query(
	$establishment-uri as xs:string
)
{
	let $outcome-qname := xs:QName("cabi:outcome")
	let $establishment-uri-qname := xs:QName("cabi:establishment")
	return cts:element-query($outcome-qname,cts:element-value-query($establishment-uri-qname, $establishment-uri,"exact"))
};

declare private function get-impact-query(
	$impact-uri as xs:string
)
{
	let $outcome-qname := xs:QName("cabi:outcome")
	let $impact-uri-qname := xs:QName("cabi:impact")
	return cts:element-query($outcome-qname,cts:element-value-query($impact-uri-qname, $impact-uri,"exact"))
};

declare private function get-result-query(
	$result-uri as xs:string
)
{
	let $outcome-qname := xs:QName("cabi:outcome")
	let $result-uri-qname := xs:QName("cabi:result")
	return cts:element-query($outcome-qname,cts:element-value-query($result-uri-qname, $result-uri,"exact"))
};

declare private function get-location-introduced-to-query(
	$location-introduced-to-uri as xs:string
)
{
	let $introduced-to-qname := xs:QName("cabi:introduced-to")
	let $country-uri-qname := xs:QName("cabi:country")
	let $bio-geographic-range-uri-qname := xs:QName("cabi:bio-geographic-range-uri")
	let $country-region-uri-qname := xs:QName("cabi:country-region")
	return cts:element-query(
								$introduced-to-qname,
								wrap-in-or (	
												(
													cts:element-value-query($country-uri-qname, $location-introduced-to-uri,"exact"),
													cts:element-value-query($bio-geographic-range-uri-qname, $location-introduced-to-uri,"exact"),
													cts:element-value-query($country-region-uri-qname, $location-introduced-to-uri,"exact")					
												)
											)
							)
};

declare private function get-location-exported-from-query(
	$location-export-from-uri as xs:string
)
{
	let $exported-from-qname := xs:QName("cabi:exported-from")
	let $country-uri-qname := xs:QName("cabi:country")
	let $bio-geographic-range-uri-qname := xs:QName("cabi:bio-geographic-range-uri")
	let $country-region-uri-qname := xs:QName("cabi:country-region")
	return cts:element-query(
								$exported-from-qname,
								wrap-in-or (	
												(
													cts:element-value-query($country-uri-qname, $location-export-from-uri,"exact"),
													cts:element-value-query($bio-geographic-range-uri-qname, $location-export-from-uri,"exact"),
													cts:element-value-query($country-region-uri-qname, $location-export-from-uri,"exact")					
												)
											)
							)
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