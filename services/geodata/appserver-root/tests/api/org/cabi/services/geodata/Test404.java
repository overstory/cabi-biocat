package org.cabi.services.geodata;

/**
 * Created by BartonP on 21/10/2014.
 */
import org.junit.Test;
import static com.jayway.restassured.RestAssured.*;
import static org.hamcrest.Matchers.not;

/**
 * Created by IntelliJ IDEA.
 * User: BartonP
 * Date: 2014 10 21
 * Time: 13:39
 */

public class Test404 extends GeoDataTest
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