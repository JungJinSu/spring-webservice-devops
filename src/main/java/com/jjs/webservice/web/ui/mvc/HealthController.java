package com.jjs.webservice.web.ui.mvc;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.boot.actuate.health.Health;

@RestController
public class HealthController {

    private static Logger logger = LogManager.getLogger(HealthController.class);

    @Autowired
    private HealthCheck healthcheck;

    //헬스체크
    @GetMapping("/health")
    public Health checkHealth() {
        return healthcheck.health();
    }
}


