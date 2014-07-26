package org.magnum.mobilecloud.video.servlet

import java.io.IOException
import java.util.concurrent.CopyOnWriteArrayList
import javax.servlet.ServletException
import javax.servlet.http.HttpServlet
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.magnum.mobilecloud.annotations.Serializable

import static com.google.common.net.MediaType.*
import javax.servlet.annotation.WebServlet

/**
 * Adds an html form to capture and display video metadata. 
 * Allows clients to send HTTP POST
 * requests with videos that are stored in memory using a list.
 * Clients can send HTTP GET requests to receive a 
 * listing of the videos that have been sent to the servlet
 * so far. Stopping the servlet will cause it to lose the history
 * of videos that have been sent to it because they are stored
 * in memory.
 * 
 * @author jules
 * @author Anonymous
 *
 */
@WebServlet(
    displayName="Echo Application",
    description="This is an application that will echo any message received via the msg parameter back to the client.",
    name="HtmlVideoServlet",
	urlPatterns = #["/view/video"]
) 
@Serializable 
public class HtmlVideoServlet extends HttpServlet // Servlets should inherit HttpServlet
{
	public static val String VIDEO_ADDED = "Video added."
    // An in-memory list that the servlet uses to store the
    // videos that are sent to it by clients
    private val videos = new CopyOnWriteArrayList<Video>
    private static val HTML_LINE_BREAK = "<br />"
    
    protected def void processRequest(HttpServletRequest req, HttpServletResponse it)
            throws ServletException, IOException {

        // Make sure and set the content-type header so that the client
        // can properly (and securely!) display the content that you send
        // back
        setContentType(HTML_UTF_8.toString)

        // This PrintWriter allows us to write data to the HTTP 
        // response body that is going to be sent to the client.
        val extension sendToClient = writer
        
        // UI form
        write(
        	(new Form => [
            	name='formvideo' 
            	method=FormMethod.POST 
            	target='_self'
            	fieldset = new FieldSet => [
		            legend="Video Data"
		            table = new Table => [
		            	labelAndValueList += new LabelAndValue => [
		            		id="name"
		            		label = new Label => [ value = "Name" ]
		            		input = new Input => [
		            			type=InputType.TEXT
								name='name'
								size=64
								maxLength=64
		            		]
		            	]	
		            	labelAndValueList += new LabelAndValue => [
		            		id="url"
		            		label = new Label => [ value = "URL" ]
		            		input = new Input => [
		            			type=InputType.TEXT
								name='name'
								size=64
								maxLength=256
		            		]
		            	]	
		            	labelAndValueList += new LabelAndValue => [
		            		id="duration"
		            		label = new Label => [ value = "Duration" ]
		            		input = new Input => [
		            			type=InputType.TEXT
								name='name'
								size=16
								maxLength=16
		            		]
		            	]
		            	trs += new TR => [
		            		tds += new TD => [
		            			style = new Style => [ textAlign=TextAlign.RIGHT ]
		            			colspan=2
		            			input = new Input => [
			            			type=InputType.SUBMIT
									value='Add Video'
		            			]
		            		]
		            	]
		            ]
            	]
        	]).toHtml.toString
        )
        
        // Loop through all of the stored videos and print them out
        // for the client to see.
        this.videos.forEach[
            // For each video, write its name and URL into the HTTP
            // response body
            write('''«name» : «url» («duration»)«HTML_LINE_BREAK»''')
        ]
        sendToClient.write((new Html => [ body = new Body]).toEndHtml.toString)
    }
    
    /**
     * This method processes all of the HTTP GET requests routed to the
     * servlet by the web container. This method loops through the lists
     * of videos that have been sent to it and generates a plain/text 
     * list of the videos that is sent back to the client.
     * 
     */
    override doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
    	resp.writer.write((new Html => [ body = new Body]).toStartHtml.toString)
        processRequest(req, resp)
    }

    /**
     * This method handles all HTTP POST requests that are routed to the
     * servlet by the web container.
     * 
     * Sending a post to the servlet with 'name', 'duration', and 'url' 
     * parameters causes a new video to be created and added to the list of 
     * videos. 
     * 
     * If the client fails to send one of these parameters, the servlet generates 
     * an HTTP error 400 (Bad request) response indicating that a required request
     * parameter was missing.
     */
    override doPost(HttpServletRequest req, HttpServletResponse it)
            throws ServletException, IOException {
        
        // First, extract the HTTP request parameters that we are expecting
        // from either the URL query string or the url encoded form body
        val name = req.getParameter(Video.PARAM_name)
        val url = req.getParameter(Video.PARAM_url)
        val durationStr = req.getParameter(Video.PARAM_duration)
        
        // Check that the duration parameter provided by the client
        // is actually a number
        val duration = try{
            Long.parseLong(durationStr)
        } catch (NumberFormatException e) {
            // The client sent us a duration value that wasn't a number!
            -1
        }

        // Now, the servlet has to look at each request parameter that the
        // client was expected to provide and make sure that it isn't null,
        // empty, etc.
        if (name == null || url == null || durationStr == null
                || name.trim.length < 1 || url.trim.length < 10
                || durationStr.trim.length < 1
                || duration <= 0) {
            
            // If the parameters pass our basic validation, we need to 
            // send an HTTP 400 Bad Request to the client and give it
            // a hint as to what it got wrong.
            setContentType(HTML_UTF_8.toString)
            sendError(400, '''Missing ['«Video.FIELD_NAMES.join(", ")»'].''')
        } 
        else {
            // It looks like the client provided all of the data that
            // we need, use that data to construct a new Video object
            // Add the video to our in-memory list of videos
            videos += new Video(name, url, duration)
            
            // Let the client know that we successfully added the video
            // by writing a message into the HTTP response body
            writer.write((new Html => [ body = new Body]).toStartHtml.toString + VIDEO_ADDED)
            
            processRequest(req, it)
        }
    }
}