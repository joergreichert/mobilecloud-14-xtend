package org.magnum.mobilecloud.video;

import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.web.SpringBootServletInitializer;

public class ApplicationServletInitializer extends SpringBootServletInitializer {

    override configure(SpringApplicationBuilder application) {
        application.sources(Application)
    }
}