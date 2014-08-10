package org.magnum.mobilecloud.video

import java.util.UUID

import org.magnum.mobilecloud.video.repository.Video

import com.fasterxml.jackson.databind.ObjectMapper

import static extension java.lang.Math.*

/**
 * This is a utility class to aid in the construction of
 * Video objects with random names, urls, and durations.
 * The class also provides a facility to convert objects
 * into JSON using Jackson, which is the format that the
 * VideoSvc controller is going to expect data in for
 * integration testing.
 * 
 * @author jules
 *
 */
public class TestData {

	private static val objectMapper = new ObjectMapper
	
	/**
	 * Construct and return a Video object with a
	 * rnadom name, url, and duration.
	 * 
	 * @return
	 */
	public static def Video randomVideo() {
		// Information about the video
		// Construct a random identifier using Java's UUID class
		val id = UUID.randomUUID.toString
		val title = '''Video-«id»'''
		val url = '''http://coursera.org/some/video-«id»'''
		val duration = 60 * (random * 60).rint as int * 1000 // random time up to 1hr
		return new Video(title, url, duration)
	}
	
	/**
	 *  Convert an object to JSON using Jackson's ObjectMapper
	 *  
	 * @param o
	 * @return
	 * @throws Exception
	 */
	public static def String toJson(Object o) throws Exception{
		return objectMapper.writeValueAsString(o)
	}
}
