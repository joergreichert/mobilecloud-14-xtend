package org.magnum.mobilecloud.integration.test;

import retrofit.client.ApacheClient;

public class UnsafeApacheClient extends ApacheClient {
	
	public UnsafeApacheClient() {
		super(UnsafeHttpsClient.createUnsafeClient());
	}
}
