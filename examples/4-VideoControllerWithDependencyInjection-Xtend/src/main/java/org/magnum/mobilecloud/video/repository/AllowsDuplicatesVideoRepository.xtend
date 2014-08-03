package org.magnum.mobilecloud.video.repository

import java.util.concurrent.CopyOnWriteArrayList
import org.magnum.mobilecloud.video.controller.Video

/**
 * An implementation of the VideoRepository that allows duplicate
 * Videos. 
 * 
 * Yes...there is a lot of code duplication with NoDuplicatesVideoRepository
 * that could be refactored into a base class or helper object. The
 * goal was to have as few classes as possible in the example and so
 * we did not do that refactoring.
 * 
 * @author jules
 *
 */
public class AllowsDuplicatesVideoRepository implements VideoRepository {

	// Lists allow duplicate objects that are .equals() to
	// each other
	//
	// Assume a lot more reads than writes
	private val videoList = new CopyOnWriteArrayList<Video>
	
	override addVideo(Video v) {
		videoList += v
	}

	override getVideos() {
		videoList
	}

	// Search the list of videos for ones with
	// matching titles.
	override findByTitle(String title) {
		videoList.filter[name == title].toSet
	}

}
