xquery version "1.0-ml";

module namespace tlib = "urn:cabi.org:namespace:module:lib:taxonomy";

declare namespace tax = "http://namespaces.cabi.org/namespaces/cabi/taxonomy";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $collection-name := "urn:cabi.org:id:collection:taxonomy";

declare function get-item-by-id (
	$id as xs:string
) as element(tax:taxonomy-item)?
{
    (: Input id: urn:cabi.org:id:taxonomy:XXX, Thesaurus id: http://id.cabi.org/cabt/C/#XXX :)
    let $unique := fn:substring-after ($id, "urn:cabi.org:id:taxonomy:")
    let $thes-uri := "http://id.cabi.org/cabt/C/#" || $unique
    let $el-qname := xs:QName ("skos:Concept")
    let $attr-qname := xs:QName ("rdf:about")
    let $query := cts:element-attribute-value-query ($el-qname, $attr-qname, $thes-uri, "exact")
    let $result as element(skos:Concept)? := cts:search (fn:collection ($collection-name)/rdf:RDF/skos:Concept, $query)

    return
    if (fn:empty ($result))
    then ()
    else
    <tax:taxonomy-item>
        <tax:uri>{ $id }</tax:uri>
        <tax:name>{ $unique }</tax:name>
        { $result }
    </tax:taxonomy-item>
};



