package org.magnum.mobilecloud.controller.test

import org.junit.Test
import org.magnum.mobilecloud.video.controller.Video
import org.magnum.mobilecloud.video.controller.VideoSvc

import static org.junit.Assert.assertTrue

/**
 * 
 * This test constructs a VideoSvc object, adds a Video to it, and then
 * checks that the Video is returned when getVideoList() is called.
 * 
 * 
 * To run this test, right-click on it in Eclipse and select
 * "Run As"->"JUnit Test"
 * 
 * Pay attention to how the test that actually uses HTTP and this test that
 * just directly makes method calls on a VideoSvc object are essentially
 * identical. All that changes is the setup of the videoService variable.
 * Yes, this could be refactored to eliminate code duplication...but the
 * goal was to show how much Retrofit simplifies interaction with our 
 * service!
 * 
 * @author jules
 *
 */
public class VideoSvcTest {
	
	private val videoService = new VideoSvc

	/**
	 * This test creates a Video, adds the Video to the VideoSvc, and then
	 * checks that the Video is included in the list when getVideoList() is
	 * called.
	 * 
	 * @throws Exception
	 */
	@Test
	public def void testVideoAddAndList() throws Exception {
		// Information about the video
		val title = "Programming Cloud Services for Android Handheld Systems"
		val url = "http://coursera.org/some/video"
		val duration = 60 * 10 * 1000 // 10min in milliseconds
		val video = new Video(title, url, duration)

		// Test the servlet directly, without going through the network.
		val ok = videoService.addVideo(video)
		assertTrue(ok)
		
		val videos = videoService.videoList
		assertTrue(videos.contains(video))
	}
}
