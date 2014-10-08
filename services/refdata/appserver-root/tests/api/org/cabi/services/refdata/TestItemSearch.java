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

public class TestItemSearch extends RefDataTest
{
	@BeforeClass
	public static void setupDB() throws IOException
	{
		clearDb();
		loadDbFromResource ("category/searchbundle1.xml");
	}


	@Test
	public void shouldReturnZeroItemsForImpactCategory ()
	{
		String categoryId = "urn:cabi.org:id:refdata:category:impact";

		given ()
			.config (xmlConfig)
			.header ("Accept", "application/atom+xml")
		.when ()
			.get ("/category/id/" + categoryId + "/item")
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("application/atom+xml")
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@href", usingNamespaces, equalTo ("/refdata/category/id/urn:cabi.org:id:refdata:category:impact/item")))
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@type", usingNamespaces, equalTo ("application/atom+xml")))
			.body (hasXPath ("count(/atom:feed/atom:entry)", usingNamespaces, equalTo ("0")))
//			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@type", usingNamespaces, equalTo ("applicaton/vnd.cabi.org:refdata:item+xml")))
		;
	}

	@Test
	public void shouldReturnOneItemForCountryCategory ()
	{
		String categoryId = "urn:cabi.org:id:refdata:category:country";
		String itemId = "urn:cabi.org:id:refdata:category:country:gb";

		given ()
			.config (xmlConfig)
			.header ("Accept", "application/atom+xml")
		.when ()
			.get ("/category/id/" + categoryId + "/item")
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("application/atom+xml")
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@href", usingNamespaces, equalTo ("/refdata/category/id/" + categoryId + "/item")))
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@type", usingNamespaces, equalTo ("application/atom+xml")))
			.body (hasXPath ("count(/atom:feed/atom:entry)", usingNamespaces, equalTo ("1")))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/@type", usingNamespaces, equalTo ("applicaton/vnd.cabi.org:refdata:item+xml")))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/rd:refdata/rd:uri", usingNamespaces, equalTo (itemId)))
		;
	}

	@Test
	public void shouldReturnOneItemForEstablishmentCategory ()
	{
		String categoryId = "urn:cabi.org:id:refdata:category:establishment";
		String itemId1 = "urn:cabi.org:id:refdata:category:establishment:fail";
		String itemId2 = "urn:cabi.org:id:refdata:category:establishment:partial";

		given ()
			.config (xmlConfig)
			.header ("Accept", "application/atom+xml")
		.when ()
			.get ("/category/id/" + categoryId + "/item")
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("application/atom+xml")
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@href", usingNamespaces, equalTo ("/refdata/category/id/" + categoryId + "/item")))
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@type", usingNamespaces, equalTo ("application/atom+xml")))
			.body (hasXPath ("count(/atom:feed/atom:entry)", usingNamespaces, equalTo ("2")))
			.body (hasXPath ("/atom:feed/atom:entry[1]/atom:content/@type", usingNamespaces, equalTo ("applicaton/vnd.cabi.org:refdata:item+xml")))
			.body (hasXPath ("/atom:feed/atom:entry[2]/atom:content/@type", usingNamespaces, equalTo ("applicaton/vnd.cabi.org:refdata:item+xml")))
			.body (hasXPath ("/atom:feed/atom:entry[atom:content/rd:refdata/rd:uri = '" + itemId1 + "']/atom:link[@rel = 'self']/@href", usingNamespaces, equalTo ("/refdata/item/id/" + itemId1)))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/rd:refdata[rd:uri = '" + itemId1 + "']/rd:display-name", usingNamespaces, equalTo ("Not Established")))
			.body (hasXPath ("/atom:feed/atom:entry[atom:content/rd:refdata/rd:uri = '" + itemId2 + "']/atom:link[@rel = 'self']/@href", usingNamespaces, equalTo ("/refdata/item/id/" + itemId2)))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/rd:refdata[rd:uri = '" + itemId2 + "']/rd:display-name", usingNamespaces, equalTo ("Partial Establishment")))
		;
	}

	@Test
	public void shouldReturnFailItemForEstablishmentCategory ()
	{
		String categoryId = "urn:cabi.org:id:refdata:category:establishment";
		String itemId = "urn:cabi.org:id:refdata:category:establishment:fail";

		given ()
			.config (xmlConfig)
			.header ("Accept", "application/atom+xml")
			.queryParam ("word", "trombone")
		.when ()
			.get ("/category/id/" + categoryId + "/item")
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("application/atom+xml")
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@href", usingNamespaces, equalTo ("/refdata/category/id/" + categoryId + "/item?word=trombone")))
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@type", usingNamespaces, equalTo ("application/atom+xml")))
			.body (hasXPath ("count(/atom:feed/atom:entry)", usingNamespaces, equalTo ("1")))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/@type", usingNamespaces, equalTo ("applicaton/vnd.cabi.org:refdata:item+xml")))
			.body (hasXPath ("/atom:feed/atom:entry/atom:content/rd:refdata/rd:uri", usingNamespaces, equalTo (itemId)))
		;
	}

	@Test
	public void shouldReturnNothingForEstablishmentCategorySearch ()
	{
		String categoryId = "urn:cabi.org:id:refdata:category:establishment";

		given ()
			.config (xmlConfig)
			.header ("Accept", "application/atom+xml")
			.queryParam ("word", "supercalifragilisticexpealidocious")
		.when ()
			.get ("/category/id/" + categoryId + "/item")
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("application/atom+xml")
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@href", usingNamespaces, equalTo ("/refdata/category/id/" + categoryId + "/item?word=supercalifragilisticexpealidocious")))
			.body (hasXPath ("/atom:feed/atom:link[@rel = 'self']/@type", usingNamespaces, equalTo ("application/atom+xml")))
			.body (hasXPath ("count(/atom:feed/atom:entry)", usingNamespaces, equalTo ("0")))
		;
	}
}


