package org.magnum.mobilecloud.integration.test

import org.apache.http.client.HttpClient
import org.apache.http.conn.ssl.SSLConnectionSocketFactory
import org.apache.http.conn.ssl.SSLContextBuilder
import org.apache.http.conn.ssl.TrustSelfSignedStrategy
import org.apache.http.impl.client.HttpClients

/**
 * This is an example of an HTTP client that does not properly
 * validate SSL certificates that are used for HTTPS. You should
 * NEVER use a client like this in a production application. Self-signed
 * certificates are usually only OK for testing purposes, such as
 * this use case. 
 * 
 * @author jules
 *
 */
public class UnsafeHttpsClient {

	public static def HttpClient createUnsafeClient() {
		try {
			HttpClients.custom.setSSLSocketFactory(
				new SSLConnectionSocketFactory((new SSLContextBuilder => [
					loadTrustMaterial(null, new TrustSelfSignedStrategy)	
				]).build)).build
		} catch (Exception e) {
			throw new RuntimeException(e)
		}
	}
}
