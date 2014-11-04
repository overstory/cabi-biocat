package org.cabi.services.geodata;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import java.io.IOException;

import static com.jayway.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasXPath;
import static org.hamcrest.Matchers.not;

/**
 * Created by BartonP on 21/10/2014.
 */
public class TestGeoDataById extends GeoDataTest {

    public static final String BOGUS_ID = "i-am-a-bogus-item-id";
    @Test
    public void shouldReturn404ForNoItem()
    {
        given ()
                .config (xmlConfig)
                .header ("Accept", "applicaton/vnd.cabi.org:geodata:item+xml")
                .when ()
                .get("/id/" + BOGUS_ID)
                .then()
                .log().ifStatusCodeMatches(not(404))
                .statusCode(404)
                .contentType("application/vnd.cabi.org:errors+xml")
                .body(hasXPath("/e:errors/e:resource-not-found/e:id", usingNamespaces, equalTo(BOGUS_ID)))
        ;
    }


    @BeforeClass
    public static void setup() throws IOException
    {
        clearDb();
        loadDbFromResource("example/geodata.xml");
    }

    @Test
    public void shouldReturn200ForItem()
    {
        String id = "urn:cabi.org:id:geodata:2014-10-21:12345";
        given()
                .config(xmlConfig)
                .header("Accept", "application/vnd.cabi.org:geodata:item+xml")
                .when()
                .get("/id/" +id)
                .then()
                .log().ifStatusCodeMatches(not(200))
                .statusCode(200)
                .contentType("application/vnd.cabi.org:geodata:item+xml")
                .body(hasXPath("/gd:geodata-item/gd:uri", usingNamespaces, equalTo(id)));
    }
}
