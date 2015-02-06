package org.magnum.mobilecloud.video.repository;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAutoGeneratedKey
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable
import org.magnum.mobilecloud.annotations.Data

/**
 * A simple object to represent a video and its URL for viewing.
 * 
 * @author jules
 * 
 */
@DynamoDBTable(tableName="Video")
@Data(generateEmptyConstructor=true)
public class Video {

	@DynamoDBHashKey
	@DynamoDBAutoGeneratedKey
	private String id

	@DynamoDBAttribute
	private String name

	@DynamoDBAttribute
	private String url

	@DynamoDBAttribute
	private long duration

	new(String name, String url, long duration) {
		this.name = name
		this.url = url
		this.duration = duration
	}
}