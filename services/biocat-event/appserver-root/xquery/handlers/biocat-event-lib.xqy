xquery version "1.0-ml";
module namespace biocat-events-lib = "urn:cabi.org:namespace:module:lib:biocat-events";

import module namespace mem = "http://xqdev.com/in-mem-update" at '/MarkLogic/appservices/utils/in-mem-update.xqy';

declare namespace rd = "http://namespaces.cabi.org/namespaces/cabi/refdata";
declare namespace cabi = "http://namespaces.cabi.org/namespaces/cabi";
declare namespace biol = "http://ontologi.es/biol/ns";
declare namespace dcterms = "http://purl.org/dc/terms";

declare variable $biocat-events-collection-name := "urn:cabi.org:id:collection:biocat:event";

declare variable $BIOCAT-EVENTS-COLLECTIONS := ($biocat-events-collection-name);



(:agent,target,location-introduced-to, location-exported-from,establishment :)
(:biocat{?terms,year,year-range,,crop,,genus,order,,impact,result,page,ipp,facets}:)


declare function search-biocat-event-items (
	$terms as xs:string?,
	$year as xs:int?,
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
	$page as xs:int?,
	$ipp as xs:int?,
	$facets as xs:string?	
)
 as element(cabi:bio-event)*
{
    let $query :=
        wrap-in-and ((
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
			if (fn:exists ($establishment)) 
				then
					wrap-in-or(
						for $establishment-exported-from-uri-value in fn:tokenize($establishment,",")
						return  get-establishment-query($establishment-exported-from-uri-value)
					)
				else ()
        ))
	return cts:search (fn:collection ($BIOCAT-EVENTS-COLLECTIONS), $query)/cabi:bio-event
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
    then ()
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