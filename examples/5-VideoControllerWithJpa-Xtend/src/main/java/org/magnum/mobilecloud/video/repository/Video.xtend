package org.magnum.mobilecloud.video.repository;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import com.google.common.base.Objects;

/**
 * A simple object to represent a video and its URL for viewing.
 * 
 * @author jules
 * 
 */
@Entity
public class Video {

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	@de.oehme.xtend.contrib.Property private long id;

	@de.oehme.xtend.contrib.Property private String name;
	@de.oehme.xtend.contrib.Property private String url;
	@de.oehme.xtend.contrib.Property private long duration;

	new () {
	}

	public new(String name, String url, long duration) {
		super();
		this.name = name;
		this.url = url;
		this.duration = duration;
	}
	/**
	 * Two Videos will generate the same hashcode if they have exactly the same
	 * values for their name, url, and duration.
	 * 
	 */
	override hashCode() {
		// Google Guava provides great utilities for hashing
		Objects.hashCode(name, url, duration);
	}

	/**
	 * Two Videos are considered equal if they have exactly the same values for
	 * their name, url, and duration.
	 * 
	 */
	override equals(Object other) {
		switch(other) {
			// Google Guava provides great utilities for equals too!
			Video: Objects.equal(name, other.name)
					&& Objects.equal(url, other.url)
					&& duration == other.duration
			default: false
		}
	}

}
