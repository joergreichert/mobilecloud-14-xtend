package org.magnum.mobilecloud.video.servlet.test

import com.google.common.io.Closer
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.util.Properties
import java.util.UUID
import org.apache.commons.io.IOUtils
import org.apache.http.Consts
import org.apache.http.HttpResponse
import org.apache.http.client.entity.UrlEncodedFormEntity
import org.apache.http.client.methods.HttpGet
import org.apache.http.client.methods.HttpPost
import org.apache.http.impl.client.HttpClients
import org.apache.http.message.BasicNameValuePair
import org.junit.Test
import org.magnum.mobilecloud.video.servlet.VideoServlet

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertTrue
import static org.magnum.mobilecloud.video.servlet.test.Constants.*
import org.magnum.mobilecloud.video.servlet.Video

/**
 * 
 * This test sends a POST request to the VideoServlet to add a new video and
 * then sends a second GET request to check that the video showed up in the list
 * of videos.
 * 
 * The test requires that the servlet be running first (see the directions in
 * the README.md file for how to launch the servlet in a web container.
 * 
 * The test uses the Apache HttpClient that is part of the HTTP Components project.
 * This library is not covered in the videos. Instead, of showing how to use these
 * lower-level libraries, which should be straightforward if you understand the HTTP
 * concepts and refer to their documentation, the videos cover the more type safe
 * and easier to use Retrofit client. However, at this point, we haven't covered
 * Retrofit and JSON yet, so we use the HttpClient.
 * 
 * 
 * To run this test, right-click on it in Eclipse and select
 * "Run As"->"JUnit Test"
 * 
 * @author jules
 *
 */
public class VideoServletHttpTest {
	private String httpPort = {
		val closer = Closer.create
		try {
			val in = closer.register(new FileInputStream(new File("gradle.properties")))
			(new Properties => [load(in)]).get("localHttpPort") as String
		} catch (Throwable e) {
			throw closer.rethrow(e)
		} finally {
			closer.close
		}
	}

	private val TEST_URL = '''http://localhost:«httpPort»/«PROJECT_NAME»/video'''

	// The HTTP client or "fake browser" that we are going to sue to send
	// requests to the VideoServlet
	private val httpClient = HttpClients.createDefault

	/**
	 * This test sends a POST request to the VideoServlet to add a new video and
	 * then sends a second GET request to check that the video showed up in the
	 * list of videos.
	 * 
	 * This is quite long for a test method, but is meant to show how to do
	 * a full add/list cycle interaction with the VideoServlet.
	 * 
	 * @throws Exception
	 */
	@Test
	def void testVideoAddAndList() throws Exception {

		// Information about the video
		// We create a random String for the title so that we can ensure
		// that the video is added after every run of this test. 
		val myRandomID = UUID.randomUUID.toString
		val title = '''Video - «myRandomID»'''
		val videoUrl = '''http://coursera.org/some/video-«myRandomID»'''
		val duration = 60 * 10 * 1000 // 10min in milliseconds

		// Create the HTTP POST request to send the video to the server
		val post = createVideoPostRequest(title, videoUrl, duration)

		// Use our HttpClient to send the POST request and obtain the
		// HTTP response that the server sends back.
		val response = httpClient.execute(post)

		// Check that we got an HTTP 200 OK response code
		assertEquals(200, response.statusLine.statusCode)

		// Retrieve the HTTP response body from the HTTP response
		val responseBody = extractResponseBody(response)

		// Make sure that the response is what we expect. Rather than trying to
		// keep the response message from the VideoServlet in synch with this
		// test, we simply use a public static final variable on the VideoServlet so
		// that we can refer to the message in both places and avoid the test and
		// servlet definition of the message drifting out of synch.
		assertEquals(VideoServlet.VIDEO_ADDED, responseBody)

		// Now that we have posted the video to the server, we construct
		// an HTTP GET request to fetch the list of videos from the VideoServlet
		val getVideoList = new HttpGet(TEST_URL)

		// Execute our GET request and obtain the server's HTTP response
		val listResponse = httpClient.execute(getVideoList)

		// Check that we got an HTTP 200 OK response code
		assertEquals(200, listResponse.statusLine.statusCode)

		// Extract the HTTP response body from the HTTP response
		val receivedVideoListData = extractResponseBody(listResponse)

		// Construct a representation of the text that we are expecting
		// to see in the response representing our video
		val expectedVideoEntry = '''«title» : «videoUrl»'''

		// Check that our video shows up in the list by searching for the
		// expectedVideoEntry in the text of the response body
		assertTrue(receivedVideoListData.contains(expectedVideoEntry))
	}

	/**
	 * This test sends a POST request to the VideoServlet and supplies an
	 * empty String for the "name" parameter, which should cause the
	 * VideoServlet to generate an error 400 Bad request response.
	 * 
	 * @throws Exception
	 */
	@Test
	def void testMissingRequestParameter() throws Exception {

		// Information about the video
		// We create a random String for the title so that we can ensure
		// that the video is added after every run of this test. 
		// We are going to purposely send an empty String for the title
		// in this test and ensure that the VideoServlet generates a 400
		// response code.
		val title = ""
		val myRandomID = UUID.randomUUID.toString
		val videoUrl = '''http://coursera.org/some/video-«myRandomID»'''
		val duration = 60 * 10 * 1000 // 10min in milliseconds

		// Create the HTTP POST request to send the video to the server
		val post = createVideoPostRequest(title, videoUrl, duration)

		// Use our HttpClient to send the POST request and obtain the
		// HTTP response that the server sends back.
		val response = httpClient.execute(post)

		// The VideoServlet should generate an error 400 Bad request response
		assertEquals(400, response.statusLine.statusCode)
	}

	/*
	 * This simple method extracts the HTTP response body 
	 */
	private def String extractResponseBody(HttpResponse response) throws IOException {
		return IOUtils.toString(response.entity.content)
	}

	/*
	 * This method constructs a properly formatted POST request
	 * that can be sent to the VideoServlet to add a video.
	 * 
	 * @param title
	 * @param videoUrl
	 * @param duration
	 * @return
	 */
	private def HttpPost createVideoPostRequest(String title, String videoUrl, long duration) {

		// Create a POST request object using the Apache HttpClient library
		new HttpPost(TEST_URL) => [
			// Attach our url encoded Video data to the request
			// Encode the data into a url encoded request body that we can send
			// to the server with our request
			entity = new UrlEncodedFormEntity(
				// Populate the request with the name value pairs that we want to
				// send to the server representing our Video data
				newArrayList(
					new BasicNameValuePair(Video.PARAM_name, title),
					new BasicNameValuePair(Video.PARAM_url, videoUrl),
					new BasicNameValuePair(Video.PARAM_duration, String.valueOf(duration))
				),
				Consts.UTF_8
			)
		]
	}
}
