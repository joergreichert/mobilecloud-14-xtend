package org.magnum.mobilecloud.video;

import com.amazonaws.auth.BasicAWSCredentials
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient
import org.magnum.mobilecloud.annotations.SpringRun
import org.magnum.mobilecloud.video.json.ResourcesMapper
import org.socialsignin.spring.data.dynamodb.repository.config.EnableDynamoDBRepositories
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.EnableAutoConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.Configuration
import org.springframework.data.rest.webmvc.config.RepositoryRestMvcConfiguration
import org.springframework.web.servlet.config.annotation.EnableWebMvc

//Tell Spring to automatically inject any dependencies that are marked in
//our classes with @Autowired
@EnableAutoConfiguration
// Tell Spring to automatically create a JPA implementation of our
// VideoRepository
@EnableDynamoDBRepositories
// Tell Spring to turn on WebMVC (e.g., it should enable the DispatcherServlet
// so that requests can be routed to our Controllers)
@EnableWebMvc
// Tell Spring that this object represents a Configuration for the
// application
@Configuration
// Tell Spring to go and scan our controller package (and all sub packages) to
// find any Controllers or other components that are part of our applciation.
// Any class in this package that is annotated with @Controller is going to be
// automatically discovered and connected to the DispatcherServlet.
@ComponentScan
@SpringRun
public class Application extends RepositoryRestMvcConfiguration {

	//@Autowired
	//private VideoRepository repository_;
	
	
	// We are overriding the bean that RepositoryRestMvcConfiguration 
	// is using to convert our objects into JSON so that we can control
	// the format. The Spring dependency injection will inject our instance
	// of ObjectMapper in all of the spring data rest classes that rely
	// on the ObjectMapper. This is an example of how Spring dependency
	// injection allows us to easily configure dependencies in code that
	// we don't have easy control over otherwise.
	override halObjectMapper(){
		new ResourcesMapper
	}
	
    @Value("${amazon.aws.accesskey}")
    private String amazonAWSAccessKey;

    @Value("${amazon.aws.secretkey}")
    private String amazonAWSSecretKey;

    @Bean
    def amazonDynamoDB() {
        new AmazonDynamoDBClient(amazonAWSCredentials)
    }

    @Bean
    def amazonAWSCredentials() {
        new BasicAWSCredentials(amazonAWSAccessKey, amazonAWSSecretKey)
    }
}
