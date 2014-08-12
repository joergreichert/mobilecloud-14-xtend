package org.magnum.mobilecloud.integration.test

import com.google.gson.JsonObject
import java.util.UUID
import org.junit.Test
import org.magnum.mobilecloud.video.TestData
import org.magnum.mobilecloud.video.client.SecuredRestBuilder
import org.magnum.mobilecloud.video.client.SecuredRestException
import org.magnum.mobilecloud.video.client.VideoSvcApi
import retrofit.RestAdapter.LogLevel
import retrofit.RetrofitError

import static org.junit.Assert.*
import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertTrue

/**
 * 
 * This integration test sends a POST request to the VideoServlet to add a new
 * video and then sends a second GET request to check that the video showed up
 * in the list of videos. Actual network communication using HTTP is performed
 * with this test.
 * 
 * The test requires that the VideoSvc be running first (see the directions in
 * the README.md file for how to launch the Application).
 * 
 * To run this test, right-click on it in Eclipse and select
 * "Run As"->"JUnit Test"
 * 
 * Pay attention to how this test that actually uses HTTP and the test that just
 * directly makes method calls on a VideoSvc object are essentially identical.
 * All that changes is the setup of the videoService variable. Yes, this could
 * be refactored to eliminate code duplication...but the goal was to show how
 * much Retrofit simplifies interaction with our service!
 * 
 * @author jules
 *
 */
public class VideoSvcClientApiTest {

	private val String USERNAME = "admin"
	private val String PASSWORD = "pass"
	private val String CLIENT_ID = "mobile"
	private val String READ_ONLY_CLIENT_ID = "mobileReader"

	private val String TEST_URL = "https://localhost:8443"

	private val VideoSvcApi videoService = new SecuredRestBuilder()
			.setLoginEndpoint(TEST_URL + VideoSvcApi.TOKEN_PATH)
			.setUsername(USERNAME)
			.setPassword(PASSWORD)
			.setClientId(CLIENT_ID)
			.setClient(new UnsafeApacheClient)
			.setEndpoint(TEST_URL).setLogLevel(LogLevel.FULL).build()
			.create(VideoSvcApi)

	private val VideoSvcApi readOnlyVideoService = new SecuredRestBuilder()
			.setLoginEndpoint(TEST_URL + VideoSvcApi.TOKEN_PATH)
			.setUsername(USERNAME)
			.setPassword(PASSWORD)
			.setClientId(READ_ONLY_CLIENT_ID)
			.setClient(new UnsafeApacheClient)
			.setEndpoint(TEST_URL).setLogLevel(LogLevel.FULL).build()
			.create(VideoSvcApi)

	private VideoSvcApi invalidClientVideoService = new SecuredRestBuilder()
			.setLoginEndpoint(TEST_URL + VideoSvcApi.TOKEN_PATH)
			.setUsername(UUID.randomUUID.toString)
			.setPassword(UUID.randomUUID.toString)
			.setClientId(UUID.randomUUID.toString)
			.setClient(new UnsafeApacheClient)
			.setEndpoint(TEST_URL).setLogLevel(LogLevel.FULL).build()
			.create(VideoSvcApi)

	private val video = TestData.randomVideo

	/**
	 * This test creates a Video, adds the Video to the VideoSvc, and then
	 * checks that the Video is included in the list when getVideoList() is
	 * called.
	 * 
	 * @throws Exception
	 */
	@Test
	public def void testVideoAddAndList() throws Exception {
		// Add the video
		videoService.addVideo(video)

		// We should get back the video that we added above
		assertTrue(videoService.videoList.contains(video))
	}

	/**
	 * This test ensures that clients with invalid credentials cannot get
	 * access to videos.
	 * 
	 * @throws Exception
	 */
	@Test
	public def void testAccessDeniedWithIncorrectCredentials() throws Exception {

		try {
			// Add the video
			invalidClientVideoService.addVideo(video)

			fail("The server should have prevented the client from adding a video"
					+ " because it presented invalid client/user credentials")
		} catch (RetrofitError e) {
			assertTrue (e.getCause instanceof SecuredRestException)
		}
	}
	
	/**
	 * This test ensures that read-only clients can access the video list
	 * but not add new videos.
	 * 
	 * @throws Exception
	 */
	@Test
	public def void testReadOnlyClientAccess() throws Exception {

		val videos = readOnlyVideoService.videoList
		assertNotNull(videos)
		
		try {
			// Add the video
			readOnlyVideoService.addVideo(video)

			fail("The server should have prevented the client from adding a video"
					+ " because it is using a read-only client ID")
		} catch (RetrofitError e) {
			val body = e.getBodyAs(JsonObject) as JsonObject
			assertEquals("insufficient_scope", body.get("error").getAsString)
		}
	}
}
