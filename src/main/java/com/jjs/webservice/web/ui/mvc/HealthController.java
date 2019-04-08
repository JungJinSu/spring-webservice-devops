package com.jjs.webservice.web.ui.mvc;

import org.json.simple.JSONObject;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;

@RestController
public class HealthController {

    private static Logger logger = LogManager.getLogger(HealthController.class);

    // 10. 헬스체크
    @GetMapping("/health")
    @ResponseBody()
    public JSONObject checkHealth() {

        HttpServletRequest req = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
        JSONObject healthCheck= new JSONObject();

        healthCheck.put("health", "GET / 200 OK ");
        healthCheck.put("HostIp", req.getRemoteAddr());
        logger.info(healthCheck.toString());
        return healthCheck;
    }
}


