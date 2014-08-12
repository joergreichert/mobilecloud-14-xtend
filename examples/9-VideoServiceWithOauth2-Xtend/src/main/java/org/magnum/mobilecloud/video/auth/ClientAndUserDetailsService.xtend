/* 
 **
 ** Copyright 2014, Jules White
 **
 ** 
 */
package org.magnum.mobilecloud.video.auth

import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.oauth2.provider.ClientDetailsService
import org.springframework.security.oauth2.provider.ClientRegistrationException
import org.springframework.security.oauth2.provider.client.ClientDetailsUserDetailsService

/**
 * A class that combines a UserDetailsService and ClientDetailsService
 * into a single object.
 * 
 * @author jules
 *
 */
public class ClientAndUserDetailsService implements UserDetailsService,
		ClientDetailsService {

	private val ClientDetailsService clients_

	private val UserDetailsService users_
	
	private val ClientDetailsUserDetailsService clientDetailsWrapper_

	public new(ClientDetailsService clients,
			UserDetailsService users) {
		clients_ = clients
		users_ = users
		clientDetailsWrapper_ = new ClientDetailsUserDetailsService(clients_)
	}

	override loadClientByClientId(String clientId)
			throws ClientRegistrationException {
		clients_.loadClientByClientId(clientId)
	}
	
	override loadUserByUsername(String username)
			throws UsernameNotFoundException {
		try {
			users_.loadUserByUsername(username)
		} catch(UsernameNotFoundException e){
			clientDetailsWrapper_.loadUserByUsername(username)
		}
	}
}
