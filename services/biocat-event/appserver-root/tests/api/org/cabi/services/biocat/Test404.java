package org.cabi.services.biocat;

import org.junit.Test;
import static com.jayway.restassured.RestAssured.*;
import static org.hamcrest.Matchers.not;

/**
 * Created by IntelliJ IDEA.
 * User: ron
 * Date: 10/7/14
 * Time: 2:14 PM
 */

public class Test404 extends BiocatTest
{
	@Test
	public void shouldReturn404ForBadURL()
	{
		given()
			.when ()
			.get ("/bogus/url/that/does/not/exist")
			.then ()
			.log ().ifStatusCodeMatches (not (404))
			.statusCode (404)
		;
	}
}
