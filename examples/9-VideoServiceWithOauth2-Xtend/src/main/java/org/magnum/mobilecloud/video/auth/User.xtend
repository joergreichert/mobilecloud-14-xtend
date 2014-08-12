/* 
 **
 ** Copyright 2014, Jules White
 **
 ** 
 */
package org.magnum.mobilecloud.video.auth

import java.util.Collection
import org.magnum.mobilecloud.annotations.Data
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.userdetails.UserDetails

import static org.springframework.security.core.authority.AuthorityUtils.*

@Data
public class User implements UserDetails {

	public static def UserDetails create(String username, String password,
			String...authorities) {
		return new User(username, password, authorities)
	}
	
	private String username
	private String password
	private Collection<GrantedAuthority> authorities

	private new(String username, String password,
			String...authorities) {
		this.username = username
		this.password = password
		this.authorities = createAuthorityList(authorities)
	}

	override isAccountNonExpired() {
		true
	}

	override isAccountNonLocked() {
		return true
	}

	override isCredentialsNonExpired() {
		return true
	}

	override isEnabled() {
		return true
	}
}
