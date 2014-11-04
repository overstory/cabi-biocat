package org.cabi.services.taxonomy;

import com.jayway.restassured.RestAssured;
import com.jayway.restassured.config.RestAssuredConfig;
import org.cabi.services.taxonomy.SimpleNamespaceContext;
import org.junit.BeforeClass;

import javax.xml.namespace.NamespaceContext;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import static com.jayway.restassured.RestAssured.given;
import static com.jayway.restassured.config.XmlConfig.xmlConfig;
import static org.hamcrest.Matchers.isEmptyOrNullString;
import static org.hamcrest.Matchers.not;

/**
 * Created by IntelliJ IDEA.
 * User: ron
 * Date: 10/7/14
 * Time: 2:29 PM
 */
public class TaxonomyDataTest
{
	public static final String DEFAULT_BASE_URI = "http://127.0.0.1";
	public static final int DEFAULT_PORT = 12020;
	public static final String DEFAULT_PATH = "/taxonomy";

	public static final String TEST_USERNAME = "admin";
	public static final String TEST_PASSWORD = "admin";
	public static final int TEST_SUPPORT_PORT = 12021;
	public static final String TEST_SUPPORT_PATH = "/test-support";

	public static final NamespaceContext usingNamespaces = new SimpleNamespaceContext()
		.withBinding ("tax", "http://namespaces.cabi.org/namespaces/cabi/taxonomy")
		.withBinding ("atom", "http://www.w3.org/2005/Atom")
		.withBinding ("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
		.withBinding ("skos", "http://www.w3.org/2004/02/skos/core#")
		.withBinding ("e", "http://namespaces.cabi.org/namespaces/errors");

	public static RestAssuredConfig xmlConfig = RestAssuredConfig.newConfig().xmlConfig (
		xmlConfig().namespaceAware (true)
	);


	@BeforeClass
	public static void setupRestAssured ()
	{
		RestAssured.baseURI = DEFAULT_BASE_URI;
		RestAssured.port = DEFAULT_PORT;
		RestAssured.basePath = DEFAULT_PATH;

		xmlConfig = xmlConfig.xmlConfig (xmlConfig.getXmlConfig().declareNamespace ("atom", "http://www.w3.org/2005/Atom"));
		xmlConfig = xmlConfig.xmlConfig (xmlConfig.getXmlConfig().declareNamespace ("skos", "http://www.w3.org/2004/02/skos/core#"));
		xmlConfig = xmlConfig.xmlConfig (xmlConfig.getXmlConfig().declareNamespace ("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
		xmlConfig = xmlConfig.xmlConfig (xmlConfig.getXmlConfig().declareNamespace ("e", "http://namespaces.cabi.org/namespaces/errors"));
		xmlConfig = xmlConfig.xmlConfig (xmlConfig.getXmlConfig().declareNamespace ("tax", "http://namespaces.cabi.org/namespaces/cabi/taxonomy"));
	}

	public static void clearDb ()
	{
		given ()
			.basePath (TEST_SUPPORT_PATH)
			.port (TEST_SUPPORT_PORT)
			.auth().digest (TEST_USERNAME, TEST_PASSWORD)
		.when ()
			.delete ("/clear-db")
		.then ()
			.log ().ifStatusCodeMatches (not (204))
			.statusCode (204)
			.body (isEmptyOrNullString())
		;
	}

	protected static void loadSkosFromResource(String resourcePath, String name)
		throws IOException
	{
		String xml = loadResourceAsString (resourcePath);

		given ()
			.basePath (TEST_SUPPORT_PATH)
			.port (TEST_SUPPORT_PORT)
			.auth().digest (TEST_USERNAME, TEST_PASSWORD)
			.body (xml)
			.contentType ("application/xml")
		.when ()
			.post ("/load-skos/" + name)
		.then ()
			.log ().ifStatusCodeMatches (not (201))
			.statusCode (201)
			.body (isEmptyOrNullString())
		;
	}

	private static String loadResourceAsString (String resourcePath) throws IOException
	{
		StringBuilder sb = new StringBuilder ();
		BufferedReader br = new BufferedReader(new InputStreamReader (TaxonomyDataTest.class.getResourceAsStream (resourcePath), "UTF-8"));
		for (int c = br.read(); c != -1; c = br.read()) sb.append((char)c);

		return sb.toString();   	}
}
