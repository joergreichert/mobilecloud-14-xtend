package org.magnum.mobilecloud.video.repository

import java.util.concurrent.ConcurrentHashMap
import org.magnum.mobilecloud.video.controller.Video

import static extension java.util.Collections.*

/**
 * An implementation of the VideoRepository that does not allow duplicate
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
public class NoDuplicatesVideoRepository implements VideoRepository {

	// Sets only store one instance of each object and will not
	// store a duplicate instance if two objects are .equals()
	// to each other.
	//
	private val videoSet = new ConcurrentHashMap<Video, Boolean>.newSetFromMap
	
	override addVideo(Video v) {
		videoSet += v
	}

	override getVideos() {
		videoSet
	}

	// Search the list of videos for ones with
	// matching titles.
	override findByTitle(String title) {
		videoSet.filter[name == title].toSet
	}

}
