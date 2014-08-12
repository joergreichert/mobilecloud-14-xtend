package org.magnum.mobilecloud.integration.test

import static org.junit.Assert.*
import static org.junit.Assert.assertTrue

import org.apache.http.HttpStatus
import org.junit.Test
import org.magnum.mobilecloud.video.TestData
import org.magnum.mobilecloud.video.client.VideoSvcApi

import retrofit.ErrorHandler
import retrofit.RestAdapter
import retrofit.RestAdapter.LogLevel
import retrofit.RetrofitError
import retrofit.client.ApacheClient

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

	private static class ErrorRecorder implements ErrorHandler {

		private RetrofitError _error

		override Throwable handleError(RetrofitError cause) {
			_error = cause
			return _error.getCause
		}

		public def getError() {
			return _error
		}
	}

	private val String TEST_URL = "https://localhost:8443"

	private VideoSvcApi videoService = new RestAdapter.Builder()
			.setClient(new UnsafeApacheClient)
			.setEndpoint(TEST_URL).setLogLevel(LogLevel.FULL).build
			.create(VideoSvcApi)

	private val video = TestData.randomVideo

	/**
	 * This test creates a Video and attempts to add it to the video service
	 * without logging in. The test checks to make sure that the request is
	 * denied and the client redirected to the login page.
	 * 
	 * @throws Exception
	 */
	@Test
	public def void testRedirectToLoginWithoutAuth() throws Exception {
		val error = new ErrorRecorder

		val videoService = new RestAdapter.Builder()
				.setClient(
						new ApacheClient(/*UnsafeHttpsClient.createUnsafeClient()*/))
				.setEndpoint(TEST_URL).setLogLevel(LogLevel.FULL)
				.setErrorHandler(error).build().create(VideoSvcApi)
		try {
			// This should fail because we haven't logged in!
			videoService.addVideo(video)

			fail("Yikes, the security setup is horribly broken and didn't require the user to login!!")

		} catch (Exception e) {
			// Ok, our security may have worked, ensure that
			// we got redirected to the login page
			assertEquals(HttpStatus.SC_MOVED_TEMPORARILY, error.getError()
					.getResponse().getStatus())
		}
	}

	/**
	 * This test creates a Video and attempts to add it to the video service
	 * without logging in. The test checks to make sure that the request is
	 * denied and the client redirected to the login page.
	 * 
	 * @throws Exception
	 */
	@Test
	public def void testDenyVideoAddWithoutLogin() throws Exception {
		val error = new ErrorRecorder

		val videoService = new RestAdapter.Builder()
				.setClient(
						new ApacheClient(/*UnsafeHttpsClient.createUnsafeClient()*/))
				.setEndpoint(TEST_URL).setLogLevel(LogLevel.FULL)
				.setErrorHandler(error).build().create(VideoSvcApi)
		try {
			// This should fail because we haven't logged in!
			videoService.addVideo(video)

			fail("Yikes, the security setup is horribly broken and didn't require the user to login!!")

		} catch (Exception e) {
			// Ok, our security may have worked, ensure that
			// we got redirected to the login page
			assertEquals(HttpStatus.SC_MOVED_TEMPORARILY, error.getError()
					.getResponse().getStatus())
		}

		// Now, let's login and ensure that the Video wasn't added
		videoService.login("coursera", "changeit")
		
		// We should NOT get back the video that we added above!
		val videos = videoService.videoList
		assertFalse(videos.contains(video))
	}

	/**
	 * This test creates a Video, adds the Video to the VideoSvc, and then
	 * checks that the Video is included in the list when getVideoList() is
	 * called.
	 * 
	 * @throws Exception
	 */
	@Test
	public def void testVideoAddAndList() throws Exception {

		videoService.login("coursera", "changeit")

		// Add the video
		videoService.addVideo(video)

		// We should get back the video that we added above
		val videos = videoService.getVideoList()
		assertTrue(videos.contains(video))
	}
	
	/**
	 * This test creates a Video, adds the Video to the VideoSvc, and then
	 * checks that the Video is included in the list when getVideoList() is
	 * called.
	 * 
	 * @throws Exception
	 */
	@Test
	public def void testLogout() throws Exception {

		videoService.login("coursera", "changeit")

		// Add the video, which should succeed
		videoService.addVideo(video)

		videoService.logout
		
		try{
			videoService.videoList
			fail("We shouldn't make it here if logout works!")
		}catch(Exception e){
			//OK, logout worked
		}

	}


}
