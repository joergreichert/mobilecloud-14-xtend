package org.magnum.mobilecloud.video.servlet;

import org.eclipse.xtend.lib.annotations.Accessors
import org.magnum.mobilecloud.annotations.DefaultConstructor
import org.magnum.mobilecloud.annotations.SimpleLiteral

/**
 * A simple object to represent a video and its URL for viewing.
 * 
 * @author jules
 * 
 */
@Accessors
@DefaultConstructor(generateEmpty=true)
@SimpleLiteral
public class Video {
	private String name;
	private String url;
	private long duration;
}
