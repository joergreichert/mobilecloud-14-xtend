package org.magnum.mobilecloud.video.client

import java.util.Collection

import org.magnum.mobilecloud.video.repository.Video

import retrofit.http.Body
import retrofit.http.GET
import retrofit.http.POST
import retrofit.http.Query

/**
 * This interface defines an API for a VideoSvc. The
 * interface is used to provide a contract for client/server
 * interactions. The interface is annotated with Retrofit
 * annotations so that clients can automatically convert the
 * 
 * 
 * @author jules
 *
 */
public interface VideoSvcApi {
	
	public static val String TITLE_PARAMETER = "title"

	// The path where we expect the VideoSvc to live
	public static val String VIDEO_SVC_PATH = "/video"

	// The path to search videos by title
	public static val String VIDEO_TITLE_SEARCH_PATH = VIDEO_SVC_PATH + "/find"

	@GET(VIDEO_SVC_PATH)
	public def Collection<Video> getVideoList()
	
	@POST(VIDEO_SVC_PATH)
	public def boolean addVideo(@Body Video v)
	
	@GET(VIDEO_TITLE_SEARCH_PATH)
	public def Collection<Video> findByTitle(@Query(TITLE_PARAMETER) String title)
	
}
