package org.cabi.services.refdata;

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

public class TestCategory extends RefDataTest
{
	public static final String BOGUS_ID = "i-am-a-bogus-category-id";

	@BeforeClass
	public static void setupDB() throws IOException
	{
		clearDb();
		loadDbFromResource ("category/bundle1.xml");
	}

	@Test
	public void shouldReturn404ForNoItem()
	{
		given ()
			.config (xmlConfig)
			.header ("Accept", "applicaton/vnd.cabi.org:refdata:item+xml")
		.when ()
			.get ("/category/id/" + BOGUS_ID)
		.then ()
			.log ().ifStatusCodeMatches (not (404))
			.statusCode (404)
			.contentType ("application/vnd.cabi.org:errors+xml")
			.body (hasXPath ("/e:errors/e:resource-not-found/e:id", usingNamespaces, equalTo (BOGUS_ID)))
		;
	}

	@Test
	public void shouldReturnSixCategories()
	{
		given ()
			.config (xmlConfig)
			.header ("Accept", "applicaton/atom+xml")
		.when ()
			.get ("/category")
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("application/atom+xml")
			.body (hasXPath ("/atom:feed/atom:link/@rel", usingNamespaces, equalTo ("self")))
			.body (hasXPath ("count(/atom:feed/atom:entry)", usingNamespaces, equalTo ("6")))
			.body (hasXPath ("count(/atom:feed/atom:entry/atom:link/@href)", usingNamespaces, equalTo ("6")))
			.body (hasXPath ("/atom:feed/atom:entry[atom:content/rd:refdata/rd:uri = 'urn:cabi.org:id:refdata:category:country']/atom:link/@href", usingNamespaces, equalTo ("/refdata/category/id/urn:cabi.org:id:refdata:category:country")))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/rd:refdata[rd:uri = 'urn:cabi.org:id:refdata:category:country']/rd:display-name", usingNamespaces, equalTo ("Country")))
			.body (hasXPath ("/atom:feed/atom:entry[atom:content/rd:refdata/rd:uri = 'urn:cabi.org:id:refdata:category:impact']/atom:link/@href", usingNamespaces, equalTo ("/refdata/category/id/urn:cabi.org:id:refdata:category:impact")))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/rd:refdata[rd:uri = 'urn:cabi.org:id:refdata:category:impact']/rd:display-name", usingNamespaces, equalTo ("Impact")))
			.body (hasXPath ("/atom:feed/atom:entry[atom:content/rd:refdata/rd:uri = 'urn:cabi.org:id:refdata:category:establishment']/atom:link/@href", usingNamespaces, equalTo ("/refdata/category/id/urn:cabi.org:id:refdata:category:establishment")))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/rd:refdata[rd:uri = 'urn:cabi.org:id:refdata:category:establishment']/rd:display-name", usingNamespaces, equalTo ("Establishment")))
		;
	}

	@Test
	public void shouldReturnSpecificCategoryById ()
	{
		String uri = "urn:cabi.org:id:refdata:category:country";

		given ()
			.config (xmlConfig)
			.header ("Accept", "applicaton/vnd.cabi.org:refdata:item+xml")
		.when ()
			.get ("/category/id/" + uri)
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("applicaton/vnd.cabi.org:refdata:item+xml")
			.body (hasXPath ("/rd:refdata/rd:uri", usingNamespaces, equalTo (uri)))
		;
	}

	@Test
	public void shouldNotReturnSpecificNonCategoryById ()
	{
		String uri = "urn:cabi.org:id:refdata:category:country:uk";

		given ()
			.config (xmlConfig)
			.header ("Accept", "applicaton/vnd.cabi.org:refdata:item+xml")
		.when ()
			.get ("/category/id/" + uri)
		.then ()
			.log ().ifStatusCodeMatches (not (404))
			.statusCode (404)
			.contentType ("application/vnd.cabi.org:errors+xml")
			.body (hasXPath ("/e:errors/e:resource-not-found/e:id", usingNamespaces, equalTo (uri)))
		;
	}

}
