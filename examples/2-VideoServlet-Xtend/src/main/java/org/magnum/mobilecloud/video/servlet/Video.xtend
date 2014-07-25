package org.magnum.mobilecloud.video.servlet;

import org.magnum.mobilecloud.annotations.SimpleLiteral

/**
 * A simple object to represent a video and its URL for viewing.
 * 
 * @author jules
 * 
 */
@Data
@SimpleLiteral
public class Video {
	private String name;
	private String url;
	private long duration;
}
