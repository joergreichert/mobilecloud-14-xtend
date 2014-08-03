package org.magnum.mobilecloud.integration.test

import com.google.common.io.Closer
import java.util.Properties
import org.junit.Test
import org.magnum.mobilecloud.video.TestData
import org.magnum.mobilecloud.video.client.VideoSvcApi
import retrofit.RestAdapter
import retrofit.RestAdapter.LogLevel

import static org.junit.Assert.assertTrue

/**
 * 
 * This integration test sends a POST request to the VideoServlet to add a new video 
 * and then sends a second GET request to check that the video showed up in the list
 * of videos. Actual network communication using HTTP is performed with this test.
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
	private String httpPort = {
		val closer = Closer.create
		try {
			val in = closer.register(VideoSvcClientApiTest.classLoader.getResourceAsStream("application.properties"))
			(new Properties => [load(in)]).get("server.port") as String
		} catch (Throwable e) {
			throw closer.rethrow(e)
		} finally {
			closer.close
		}
	}

	private final String TEST_URL = '''http://localhost:«httpPort»'''

	private val videoService = new RestAdapter.Builder()
			.setEndpoint(TEST_URL).setLogLevel(LogLevel.FULL).build
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
		val ok = videoService.addVideo(video)
		assertTrue(ok)

		// We should get back the video that we added above
		val videos = videoService.videoList
		assertTrue(videos.contains(video))
	}

}
