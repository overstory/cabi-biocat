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

public class TestItems extends RefDataTest
{
	public static final String BOGUS_ID = "i-am-a-bogus-item-id";
	@Test
	public void shouldReturn404ForNoItem()
	{
		given ()
			.config (xmlConfig)
			.header ("Accept", "applicaton/vnd.cabi.org:refdata:item+xml")
		.when ()
			.get ("/item/id/" + BOGUS_ID)
		.then ()
			.log ().ifStatusCodeMatches (not (404))
			.statusCode (404)
			.contentType ("application/vnd.cabi.org:errors+xml")
			.body (hasXPath ("/e:errors/e:resource-not-found/e:id", usingNamespaces, equalTo (BOGUS_ID)))
		;
	}
}
