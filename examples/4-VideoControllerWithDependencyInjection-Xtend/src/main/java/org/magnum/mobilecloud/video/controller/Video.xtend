package org.magnum.mobilecloud.video.controller

import com.google.common.base.Objects

/**
 * A simple object to represent a video and its URL for viewing.
 * 
 * @author jules
 * 
 */
@Data 
public class Video {

	private String name
	private String url
	private long duration

	/**
	 * Two Videos will generate the same hashcode if they have exactly
	 * the same values for their name, url, and duration.
	 * 
	 */
	override hashCode() {
		// Google Guava provides great utilities for hashing 
		return Objects.hashCode(name,url,duration)
	}

	/**
	 * Two Videos are considered equal if they have exactly
	 * the same values for their name, url, and duration.
	 * 
	 */
	override equals(Object other) {
		switch(other) {
			// Google Guava provides great utilities for equals too! 
			Video: Objects.equal(name, other.name) 
					&& Objects.equal(url, other.url)
					&& duration == other.duration
			default: false		
		}
	}
}
