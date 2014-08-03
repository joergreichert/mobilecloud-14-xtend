package org.magnum.mobilecloud.video.controller

import org.magnum.mobilecloud.annotations.Data

/**
 * A simple object to represent a video and its URL for viewing.
 * 
 * @author jules
 * 
 */
@Data(generateEmptyConstructor=true)
public class Video {

	private String name
	private String url
	private long duration
}
