package org.cabi.services.refdata;

import org.junit.Test;

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
	@Test
	public void shouldReturnEmptyAtomFeed()
	{
		given()
			.config (xmlConfig)
			.header ("Accept", "application/atom+xml")
		.when ()
			.get ("/category")
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("application/atom+xml")
			.body (hasXPath ("/atom:feed/atom:link/@rel", usingNamespaces, equalTo ("self")))
			.body (hasXPath ("/atom:feed/atom:link/@href", usingNamespaces, equalTo ("/refdata/category")))
			.body (hasXPath ("/atom:feed/atom:link/@type", usingNamespaces, equalTo ("application/atom+xml")))
			.body (hasXPath ("/atom:feed/atom:id", usingNamespaces, not (isEmptyOrNullString())))
			.body (hasXPath ("/atom:feed/atom:updated", usingNamespaces, not (isEmptyOrNullString())))
//			.body (hasXPath ("/atom:feed/atom:updated castable as xs:date", usingNamespaces))
			.body (hasXPath ("count(/atom:feed/atom:entry)", usingNamespaces, equalTo ("0")))
		;
	}
}
