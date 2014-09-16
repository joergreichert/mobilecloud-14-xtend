package org.magnum.mobilecloud.video.auth

import java.io.File

import org.apache.catalina.connector.Connector
import org.apache.coyote.http11.Http11NioProtocol
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.context.embedded.ConfigurableEmbeddedServletContainer
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer
import org.springframework.boot.context.embedded.tomcat.TomcatConnectorCustomizer
import org.springframework.boot.context.embedded.tomcat.TomcatEmbeddedServletContainerFactory
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.Ordered
import org.springframework.core.annotation.Order
import org.springframework.http.HttpMethod
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.oauth2.config.annotation.builders.InMemoryClientDetailsServiceBuilder
import org.springframework.security.oauth2.config.annotation.configurers.ClientDetailsServiceConfigurer
import org.springframework.security.oauth2.config.annotation.web.configuration.AuthorizationServerConfigurerAdapter
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableAuthorizationServer
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableResourceServer
import org.springframework.security.oauth2.config.annotation.web.configuration.ResourceServerConfigurerAdapter
import org.springframework.security.oauth2.config.annotation.web.configurers.AuthorizationServerEndpointsConfigurer
import org.springframework.security.oauth2.provider.ClientDetailsService
import org.springframework.security.provisioning.InMemoryUserDetailsManager

/**
 *	Configure this web application to use OAuth 2.0.
 *
 * 	The resource server is located at "/video", and can be accessed only by retrieving a token from "/oauth/token"
 *  using the Password Grant Flow as specified by OAuth 2.0.
 *  
 *  Most of this code can be reused in other applications. The key methods that would definitely need to
 *  be changed are:
 *  
 *  ResourceServer.configure(...) - update this method to apply the appropriate 
 *  set of scope requirements on client requests
 *  
 *  OAuth2Config constructor - update this constructor to create a "real" (not hard-coded) UserDetailsService
 *  and ClientDetailsService for authentication. The current implementation should never be used in any
 *  type of production environment as these hard-coded credentials are highly insecure.
 *  
 *  OAuth2SecurityConfiguration.containerCustomizer(...) - update this method to use a real keystore
 *  and certificate signed by a CA. This current version is highly insecure.
 *  
 */
@Configuration
public class OAuth2SecurityConfiguration {

	// This first section of the configuration just makes sure that Spring Security picks
	// up the UserDetailsService that we create below. 
	@Configuration
	@EnableWebSecurity
	protected static class WebSecurityConfiguration extends WebSecurityConfigurerAdapter {
		
		@Autowired
		private UserDetailsService userDetailsService
		
		@Autowired
		protected def void registerAuthentication(
				AuthenticationManagerBuilder auth) throws Exception {
			auth.userDetailsService(userDetailsService)
		}
	}
	
	/**
	 *	This method is used to configure who is allowed to access which parts of our
	 *	resource server (i.e. the "/video" endpoint) 
	 */
	@Configuration
	@EnableResourceServer
	protected static class ResourceServer extends
			ResourceServerConfigurerAdapter {

		// This method configures the OAuth scopes required by clients to access
		// all of the paths in the video service.
		override configure(HttpSecurity it) throws Exception {
			
			csrf.disable
			
			authorizeRequests.antMatchers("/oauth/token").anonymous
			
			
			// If you were going to reuse this class in another
			// application, this is one of the key sections that you
			// would want to change
			
			// Require all GET requests to have client "read" scope
			authorizeRequests.antMatchers(HttpMethod.GET, "/**")
				.access("#oauth2.hasScope('read')")
			
			// Require all other requests to have "write" scope
			authorizeRequests.antMatchers("/**")
				.access("#oauth2.hasScope('write')")
		}
	}

	/**
	 * This class is used to configure how our authorization server (the "/oauth/token" endpoint) 
	 * validates client credentials.
	 */
	@Configuration
	@EnableAuthorizationServer
	@Order(Ordered.LOWEST_PRECEDENCE - 100)
	protected static class OAuth2Config extends
			AuthorizationServerConfigurerAdapter {

		// Delegate the processing of Authentication requests to the framework
		@Autowired
		private AuthenticationManager authenticationManager

		// A data structure used to store both a ClientDetailsService and a UserDetailsService
		private ClientAndUserDetailsService combinedService_

		/**
		 * 
		 * This constructor is used to setup the clients and users that will be able to login to the
		 * system. This is a VERY insecure setup that is using hard-coded lists of clients / users /
		 * passwords and should never be used for anything other than local testing
		 * on a machine that is not accessible via the Internet. Even if you use
		 * this code for testing, at the bare minimum, you should consider changing the
		 * passwords listed below and updating the VideoSvcClientApiTest.
		 * 
		 * @param auth
		 * @throws Exception
		 */
		public new() throws Exception {
			
			// If you were going to reuse this class in another
			// application, this is one of the key sections that you
			// would want to change
			
			
			// Create a service that has the credentials for all our clients
			val csvc = new InMemoryClientDetailsServiceBuilder()
					// Create a client that has "read" and "write" access to the
			        // video service
					.withClient("mobile").authorizedGrantTypes("password")
					.authorities("ROLE_CLIENT", "ROLE_TRUSTED_CLIENT")
					.scopes("read","write").resourceIds("video")
					.and
					// Create a second client that only has "read" access to the
					// video service
					.withClient("mobileReader").authorizedGrantTypes("password")
					.authorities("ROLE_CLIENT")
					.scopes("read").resourceIds("video")
					.accessTokenValiditySeconds(3600).and.build

			// Create a series of hard-coded users. 
			val svc = new InMemoryUserDetailsManager(
					#[
							User.create("admin", "pass", "ADMIN", "USER"),
							User.create("user0", "pass", "USER"),
							User.create("user1", "pass", "USER"),
							User.create("user2", "pass", "USER"),
							User.create("user3", "pass", "USER"),
							User.create("user4", "pass", "USER"),
							User.create("user5", "pass", "USER")])

			// Since clients have to use BASIC authentication with the client's id/secret,
			// when sending a request for a password grant, we make each client a user
			// as well. When the BASIC authentication information is pulled from the
			// request, this combined UserDetailsService will authenticate that the
			// client is a valid "user". 
			combinedService_ = new ClientAndUserDetailsService(csvc, svc)
		}

		/**
		 * Return the list of trusted client information to anyone who asks for it.
		 */
		@Bean
		public def ClientDetailsService clientDetailsService() throws Exception {
			combinedService_
		}

		/**
		 * Return all of our user information to anyone in the framework who requests it.
		 */
		@Bean
		public def UserDetailsService userDetailsService() {
			combinedService_
		}

		/**
		 * This method tells our AuthorizationServerConfigurerAdapter to use the delegated AuthenticationManager
		 * to process authentication requests.
		 */
		override configure(AuthorizationServerEndpointsConfigurer it)
				throws Exception {
			authenticationManager(authenticationManager)
		}

		/**
		 * This method tells the AuthorizationServerConfigurerAdapter to use our self-defined client details service to
		 * authenticate clients with.
		 */
		override configure(ClientDetailsServiceConfigurer it)
				throws Exception {
			withClientDetails(clientDetailsService)
		}

	}
	
	
    // This version uses the Tomcat web container and configures it to
	// support HTTPS. The code below performs the configuration of Tomcat
	// for HTTPS. Each web container has a different API for configuring
	// HTTPS. 
	//
	// The app now requires that you pass the location of the keystore and
	// the password for your private key that you would like to setup HTTPS
	// with. In Eclipse, you can set these options by going to:
	//    1. Run->Run Configurations
	//    2. Under Java Applications, select your run configuration for this app
	//    3. Open the Arguments tab
	//    4. In VM Arguments, provide the following information to use the
	//       default keystore provided with the sample code:
	//
	//       -Dkeystore.file=src/main/resources/private/keystore -Dkeystore.pass=changeit
	//
	//    5. Note, this keystore is highly insecure! If you want more securtiy, you 
	//       should obtain a real SSL certificate:
	//
	//       http://tomcat.apache.org/tomcat-7.0-doc/ssl-howto.html
	//
    @Bean
    def EmbeddedServletContainerCustomizer containerCustomizer(
            @Value("${keystore.file:src/main/resources/private/keystore}") String keystoreFile,
            @Value("${keystore.pass:changeit}") String keystorePass) throws Exception {

		// If you were going to reuse this class in another
		// application, this is one of the key sections that you
		// would want to change
    	
        val absoluteKeystoreFile = new File(keystoreFile).getAbsolutePath

		new EmbeddedServletContainerCustomizer {
			
			override customize(ConfigurableEmbeddedServletContainer container) {
				container as TomcatEmbeddedServletContainerFactory => [
					addConnectorCustomizers([extension Connector connector |
						port = 8443
						secure = true
						scheme = "https"

						protocolHandler as Http11NioProtocol => [
							SSLEnabled = true
						
							// If you update the keystore, you need to change
							// these parameters to match the keystore that you generate
							it.keystoreFile = absoluteKeystoreFile
							it.keystorePass = keystorePass
							keystoreType = "JKS"
							keyAlias = "tomcat"
						]
					] as TomcatConnectorCustomizer)
				]
			}
		}
    }
}
