package org.magnum.mobilecloud.video;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.http.HttpStatus;
import org.magnum.mobilecloud.video.client.VideoSvcApi;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.security.web.savedrequest.NullRequestCache;

@Configuration
// Setup Spring Security to intercept incoming requests to the Controllers
@EnableWebSecurity
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {

	// This anonymous inner class' onAuthenticationSuccess() method is invoked
	// whenever a client successfully logs in. The class just sends back an
	// HTTP 200 OK status code to the client so that they know they logged
	// in correctly. The class does not redirect the client anywhere like the
	// default handler does with a HTTP 302 response. The redirect has been
	// removed to be friendlier to mobile clients and Retrofit.
	private static val NO_REDIRECT_SUCCESS_HANDLER = new AuthenticationSuccessHandler {
		override onAuthenticationSuccess(HttpServletRequest request,
				HttpServletResponse response, Authentication authentication)
				throws IOException, ServletException {
			response.status = HttpStatus.SC_OK
		}
	};
	
	// Normally, the logout success handler redirects the client to the login page. We
	// just want to let the client know that it succcessfully logged out and make the
	// response a bit of JSON so that Retrofit can handle it. The handler sends back
	// a 200 OK response and an empty JSON object.
	private static val JSON_LOGOUT_SUCCESS_HANDLER = new LogoutSuccessHandler {
		override onLogoutSuccess(HttpServletRequest request,
				HttpServletResponse it, Authentication authentication)
				throws IOException, ServletException {
			status = HttpStatus.SC_OK
			contentType = "application/json"
			writer.write("{}")
		}
	};
	
	/**
	 * This method is used to inject access control policies into Spring
	 * security to control what resources / paths / http methods clients have
	 * access to.
	 */
	override configure(HttpSecurity it) throws Exception {
		// By default, Spring inserts a token into web pages to prevent
		// cross-site request forgery attacks. 
		// See: http://en.wikipedia.org/wiki/Cross-site_request_forgery
		//
		// Unfortunately, there is no easy way with the default setup to communicate 
		// these CSRF tokens to a mobile client so we disable them.
		// Don't worry, the next iteration of the example will fix this
		// problem.
		csrf.disable
		// We don't want to cache requests during login
		requestCache.requestCache(new NullRequestCache)
		
		// Allow all clients to access the login page and use
		// it to login
		formLogin
			// The default login url on Spring is "j_security_check" ...
		    // which isn't very friendly. We change the login url to
		    // something more reasonable ("/login").
			.loginProcessingUrl(VideoSvcApi.LOGIN_PATH)
			// The default login system is designed to redirect you to
			// another URL after you successfully authenticate. For mobile
			// clients, we don't want to be redirected, we just want to tell
			// them that they successfully authenticated and return a session
			// cookie to them. this extra configuration option ensures that the 
			// client isn't redirected anywhere with an HTTP 302 response code.
			.successHandler(NO_REDIRECT_SUCCESS_HANDLER)
			// Allow everyone to access the login URL
			.permitAll
		
		// Make sure that clients can logout too!!
		logout
		    // Change the default logout path to /logout
			.logoutUrl(VideoSvcApi.LOGOUT_PATH)
			// Make sure that a redirect is not sent to the client
			// on logout
			.logoutSuccessHandler(JSON_LOGOUT_SUCCESS_HANDLER)
			// Allow everyone to access the logout URL
			.permitAll
		
		// Require clients to login and have an account with the "user" role
		// in order to access /video
		// http.authorizeRequests().antMatchers("/video").hasRole("user");
		
		// Require clients to login and have an account with the "user" role
		// in order to send a POST request to /video
		// http.authorizeRequests().antMatchers(HttpMethod.POST, "/video").hasRole("user");
		
		// We force clients to authenticate before accessing ANY URLs 
		// other than the login and lougout that we have configured above.
		authorizeRequests.anyRequest.authenticated
	}

	/**
	 * 
	 * This method is used to setup the users that will be able to login to the
	 * system. This is a VERY insecure setup that is using two hardcoded users /
	 * passwords and should never be used for anything other than local testing
	 * on a machine that is not accessible via the Internet. Even if you use
	 * this code for testing, at the bare minimum, you should change the
	 * passwords listed below.
	 * 
	 * @param auth
	 * @throws Exception
	 */
	@Autowired
	protected def void registerAuthentication(
			AuthenticationManagerBuilder auth) throws Exception {
		
		// This example creates a simple in-memory UserDetailService that
		// is provided by Spring
		auth.inMemoryAuthentication
				.withUser("coursera")
				.password("changeit")
				.authorities("admin","user")
				.and
				.withUser("student")
				.password("changeit")
				.authorities("user")
	}

}
