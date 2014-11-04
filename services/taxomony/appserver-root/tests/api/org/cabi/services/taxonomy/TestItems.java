package org.cabi.services.taxonomy;

import org.junit.BeforeClass;
import org.junit.Test;

import java.io.IOException;

import static com.jayway.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * Created by IntelliJ IDEA.
 * User: ron
 * Date: 10/7/14
 * Time: 2:14 PM
 */

public class TestItems extends TaxonomyDataTest
{
	public static final String BOGUS_ID = "i-am-a-bogus-item-id";

	@BeforeClass
	public static void setupDB() throws IOException
	{
		clearDb();
        loadSkosFromResource("thesaurus-geo.xml", "geo");
	}

	@Test
	public void shouldReturn404ForBogusItem()
	{
		given()
			.config(xmlConfig)
			.header("Accept", "applicaton/vnd.cabi.org:taxonomy:item+xml")
		.when()
			.get("/id/" + BOGUS_ID)
		.then ()
			.log ().ifStatusCodeMatches (not (404))
			.statusCode (404)
			.contentType ("application/vnd.cabi.org:errors+xml")
			.body (hasXPath ("/e:errors/e:resource-not-found/e:id", usingNamespaces, equalTo (BOGUS_ID)))
		;
	}

	@Test
	public void shouldReturnSpecificItemById()
	{
		String uri = "urn:cabi.org:id:taxonomy:Fiji";

		given ()
			.config(xmlConfig)
			.header("Accept", "applicaton/vnd.cabi.org:taxonomy:item+xml")
		.when()
			.get("/id/" + uri)
		.then()
			.log().ifStatusCodeMatches(not(200))
			.statusCode(200)
			.contentType("applicaton/vnd.cabi.org:taxonomy:item+xml")
			.body(hasXPath("/tax:taxonomy-item/tax:uri", usingNamespaces, equalTo(uri)))
			.body (hasXPath ("/tax:taxonomy-item/tax:name", usingNamespaces, equalTo ("Fiji")))
			.body (hasXPath ("/tax:taxonomy-item/skos:Concept/@rdf:about", usingNamespaces, equalTo ("http://id.cabi.org/cabt/C/#Fiji")))
		;
	}
}
