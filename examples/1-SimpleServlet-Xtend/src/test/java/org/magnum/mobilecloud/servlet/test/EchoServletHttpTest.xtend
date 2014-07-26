package org.magnum.mobilecloud.servlet.test

import com.google.common.io.Closer
import java.io.File
import java.io.FileInputStream
import java.net.URL
import java.util.Properties
import org.apache.commons.io.IOUtils
import org.junit.Test

import static org.junit.Assert.assertEquals
import static org.magnum.mobilecloud.servlet.Constants.*

/**
 * 
 * This test sends a simple GET request to the EchoServlet. The
 * test requires that the servlet be running first (see the directions
 * in the README.md file for how to launch the servlet in a web container.
 * 
 * To run this test, right-click on it in Eclipse and select 
 *   "Run As"->"JUnit Test"
 * 
 * @author jules
 *
 */
public class EchoServletHttpTest {
	private String httpPort = [|
		val closer = Closer.create
		try {
			val in = closer.register(new FileInputStream(new File("gradle.properties")))
			(new Properties => [load(in)]).get("localHttpPort") as String
		} catch (Throwable e) {
		  throw closer.rethrow(e)
		} finally {
		  closer.close
		}		
	].apply
	
	// By default, the test server will be running on localhost and listening to
	// port configured in Constants. If the server is running and you can't connect to it with this test,
	// ensure that a firewall (e.g. Windows Firewall) isn't blocking access to it.
	private val String TEST_URL = '''http://localhost:«httpPort»/«PROJECT_NAME»/echo'''
	
	/**
	 * This test sends a GET request with a msg parameter and
	 * ensures that the servlet replies with "Echo:" + msg. 
	 * 
	 * @throws Exception
	 */
	@Test
	def void testMsgEchoing() throws Exception {
		// The message to send to the EchoServlet
		val msg = "1234"
		
		// Append our message to the URL so that the
		// EchoServlet will send the message back to us
		val url = '''«TEST_URL»?msg=«msg»'''
		
		// Send an HTTP GET request to the EchoServer and
		// convert the response body to a String
		val urlobj = new URL(url)
		val content = IOUtils.toString(urlobj.openStream)
		
		// Ensure that the body of the HTTP response met our
		// expectations (e.g., it was "Echo:" + msg)
		assertEquals('''Echo:«msg»'''.toString, content)
	}
}
