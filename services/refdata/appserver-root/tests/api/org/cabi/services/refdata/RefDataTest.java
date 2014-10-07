package org.cabi.services.refdata;

import com.jayway.restassured.RestAssured;
import com.jayway.restassured.config.RestAssuredConfig;

import org.junit.BeforeClass;

import javax.xml.namespace.NamespaceContext;

import static com.jayway.restassured.config.XmlConfig.xmlConfig;

/**
 * Created by IntelliJ IDEA.
 * User: ron
 * Date: 10/7/14
 * Time: 2:29 PM
 */
public class RefDataTest
{
	public static final String DEFAULT_BASE_URI = "http://127.0.0.1";
	public static final int DEFAULT_PORT = 12000;
	public static final String DEFAULT_PATH = "/refdata";

	public static final NamespaceContext usingNamespaces = new SimpleNamespaceContext()
		.withBinding ("atom", "http://www.w3.org/2005/Atom")
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
		xmlConfig = xmlConfig.xmlConfig (xmlConfig.getXmlConfig().declareNamespace ("e", "http://namespaces.cabi.org/namespaces/errors"));
	}
}
