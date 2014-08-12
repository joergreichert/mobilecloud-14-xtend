/* 
 **
 ** Copyright 2014, Jules White
 **
 ** 
 */
package org.magnum.mobilecloud.video.client

import com.google.common.io.BaseEncoding
import com.google.gson.Gson
import com.google.gson.JsonObject
import java.util.concurrent.Executor
import org.apache.commons.io.IOUtils
import retrofit.Endpoint
import retrofit.ErrorHandler
import retrofit.Profiler
import retrofit.RequestInterceptor
import retrofit.RestAdapter
import retrofit.RestAdapter.Log
import retrofit.RestAdapter.LogLevel
import retrofit.client.Client
import retrofit.client.Client.Provider
import retrofit.client.Header
import retrofit.client.OkClient
import retrofit.client.Request
import retrofit.converter.Converter
import retrofit.mime.FormUrlEncodedTypedOutput

/**
 * A Builder class for a Retrofit REST Adapter. Extends the default implementation by providing logic to
 * handle an OAuth 2.0 password grant login flow. The RestAdapter that it produces uses an interceptor
 * to automatically obtain a bearer token from the authorization server and insert it into all client
 * requests.
 * 
 * You can use it like this:
 * 
  	private VideoSvcApi videoService = new SecuredRestBuilder()
			.setLoginEndpoint(TEST_URL + VideoSvcApi.TOKEN_PATH)
			.setUsername(USERNAME)
			.setPassword(PASSWORD)
			.setClientId(CLIENT_ID)
			.setClient(new ApacheClient(UnsafeHttpsClient.createUnsafeClient()))
			.setEndpoint(TEST_URL).setLogLevel(LogLevel.FULL).build()
			.create(VideoSvcApi.class)
 * 
 * @author Jules, Mitchell
 *
 */
public class SecuredRestBuilder extends RestAdapter.Builder {

	private static class OAuthHandler implements RequestInterceptor {

		private boolean loggedIn
		private Client client
		private String tokenIssuingEndpoint
		private String username
		private String password
		private String clientId
		private String clientSecret
		private String accessToken

		public new(Client client, String tokenIssuingEndpoint, String username,
				String password, String clientId, String clientSecret) {
			super()
			this.client = client
			this.tokenIssuingEndpoint = tokenIssuingEndpoint
			this.username = username
			this.password = password
			this.clientId = clientId
			this.clientSecret = clientSecret
		}

		/**
		 * Every time a method on the client interface is invoked, this method is
		 * going to get called. The method checks if the client has previously obtained
		 * an OAuth 2.0 bearer token. If not, the method obtains the bearer token by
		 * sending a password grant request to the server. 
		 * 
		 * Once this method has obtained a bearer token, all future invocations will
		 * automatically insert the bearer token as the "Authorization" header in 
		 * outgoing HTTP requests.
		 * 
		 */
		override intercept(RequestFacade request) {
			// If we're not logged in, login and store the authentication token.
			if (!loggedIn) {
				try {
					// This code below programmatically builds an OAuth 2.0 password
					// grant request and sends it to the server. 
					
					// Encode the username and password into the body of the request.
					val to = new FormUrlEncodedTypedOutput() => [
						addField("username", username)
						addField("password", password)
					
						// Add the client ID and client secret to the body of the request.
						addField("client_id", clientId)
						addField("client_secret", clientSecret)
					
						// Indicate that we're using the OAuth Password Grant Flow
						// by adding grant_type=password to the body
						addField("grant_type", "password")
					]
					
					// The password grant requires BASIC authentication of the client.
					// In order to do BASIC authentication, we need to concatenate the
					// client_id and client_secret values together with a colon and then
					// Base64 encode them. The final value is added to the request as
					// the "Authorization" header and the value is set to "Basic " 
					// concatenated with the Base64 client_id:client_secret value described
					// above.
					val base64Auth = BaseEncoding.base64.encode(new String(clientId + ":" + clientSecret).getBytes)
					// Add the basic authorization header
					val headers = newArrayList(new Header("Authorization", "Basic " + base64Auth))

					// Create the actual password grant request using the data above
					val req = new Request("POST", tokenIssuingEndpoint, headers, to)
					
					// Request the password grant.
					val resp = client.execute(req)
					
					// Make sure the server responded with 200 OK
					if (resp.status < 200 || resp.status > 299) {
						// If not, we probably have bad credentials
						throw new SecuredRestException("Login failure: "
								+ resp.getStatus() + " - " + resp.getReason())
					} else {
						// Extract the string body from the response
				        val body = IOUtils.toString(resp.getBody.in)
						
						// Extract the access_token (bearer token) from the response so that we
				        // can add it to future requests.
						accessToken = new Gson().fromJson(body, JsonObject).get("access_token").getAsString
						
						// Add the access_token to this request as the "Authorization"
						// header.
						request.addHeader("Authorization", "Bearer " + accessToken)	
						
						// Let future calls know we've already fetched the access token
						loggedIn = true
					}
				} catch (Exception e) {
					throw new SecuredRestException(e)
				}
			}
			else {
				// Add the access_token that we previously obtained to this request as 
				// the "Authorization" header.
				request.addHeader("Authorization", "Bearer " + accessToken )
			}
		}

	}

	private String username
	private String password
	private String loginUrl
	private String clientId
	private String clientSecret = ""
	private Client client
	
	public def SecuredRestBuilder setLoginEndpoint(String endpoint){
		loginUrl = endpoint
		this
	}

	override SecuredRestBuilder setEndpoint(String endpoint) {
		super.setEndpoint(endpoint) as SecuredRestBuilder
	}

	override SecuredRestBuilder setEndpoint(Endpoint endpoint) {
		super.setEndpoint(endpoint) as SecuredRestBuilder
	}

	override SecuredRestBuilder setClient(Client client) {
		this.client = client
		super.setClient(client) as SecuredRestBuilder
	}

	override SecuredRestBuilder setClient(Provider clientProvider) {
		client = clientProvider.get()
		super.setClient(clientProvider) as SecuredRestBuilder
	}

	override SecuredRestBuilder setErrorHandler(ErrorHandler errorHandler) {
		super.setErrorHandler(errorHandler) as SecuredRestBuilder
	}

	override SecuredRestBuilder setExecutors(Executor httpExecutor,
			Executor callbackExecutor) {
		super.setExecutors(httpExecutor, callbackExecutor) as SecuredRestBuilder
	}

	override SecuredRestBuilder setRequestInterceptor(
			RequestInterceptor requestInterceptor) {
		super.setRequestInterceptor(requestInterceptor) as SecuredRestBuilder
	}

	override SecuredRestBuilder setConverter(Converter converter) {
		super.setConverter(converter) as SecuredRestBuilder
	}

	override SecuredRestBuilder setProfiler(Profiler profiler) {
		super.setProfiler(profiler) as SecuredRestBuilder
	}

	override SecuredRestBuilder setLog(Log log) {
		return super.setLog(log) as SecuredRestBuilder
	}

	override SecuredRestBuilder setLogLevel(LogLevel logLevel) {
		return super.setLogLevel(logLevel) as SecuredRestBuilder
	}

	public def SecuredRestBuilder setUsername(String username) {
		this.username = username
		this
	}

	public def SecuredRestBuilder setPassword(String password) {
		this.password = password
		this
	}

	public def SecuredRestBuilder setClientId(String clientId) {
		this.clientId = clientId
		this
	}
	
	public def SecuredRestBuilder setClientSecret(String clientSecret) {
		this.clientSecret = clientSecret
		return this
	}

	override RestAdapter build() {
		if (username == null || password == null) {
			throw new SecuredRestException(
					"You must specify both a username and password for a "
							+ "SecuredRestBuilder before calling the build() method.")
		}

		if (client == null) {
			client = new OkClient
		}
		val hdlr = new SecuredRestBuilder.OAuthHandler(client, loginUrl, username, password, clientId, clientSecret)
		setRequestInterceptor(hdlr)

		super.build()
	}
}