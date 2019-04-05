package com.jjs.webservice.web.ui.mvc;


import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    private static Logger logger = LogManager.getLogger(HealthController.class);

    // 10. 헬스체크
    @GetMapping("/health")
    public String checkHealth() {
        logger.info("check Health");
        return "health check";
    }
}
