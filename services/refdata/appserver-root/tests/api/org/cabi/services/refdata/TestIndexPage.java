package org.cabi.services.refdata;

import org.junit.Test;

import static com.jayway.restassured.RestAssured.given;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;

/**
 * Created by IntelliJ IDEA.
 * User: ron
 * Date: 10/7/14
 * Time: 2:14 PM
 */

public class TestIndexPage extends RefDataTest
{
	@Test
	public void shouldReturnIndexPage ()
	{
		given()
			.header ("Accept", "text/html")
		.when ()
			.get ("http://127.0.0.1:12000/")
		.then ()
			.log ().ifStatusCodeMatches (not (200))
			.statusCode (200)
			.contentType ("text/html")
		.body (containsString ("Well done"))
		;
	}
}
