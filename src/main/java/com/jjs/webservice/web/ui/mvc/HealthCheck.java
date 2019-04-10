package com.jjs.webservice.web.ui.mvc;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthEndpoint;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.boot.actuate.metrics.MetricsEndpoint;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

@Component
public class HealthCheck implements HealthIndicator {


    private static Logger logger = LogManager.getLogger(HealthCheck.class);

    @Autowired
    private MetricsEndpoint metricsEndpoint;

    @Autowired
    private HealthEndpoint healthEndpoint;

    // Actuator 에서 제공하는 Endpoint 로 Custom HealthCheck
    @Override
    public Health health() {

        logger.info("HealthChecking... ");
        Map<String, Object> healthMap = new HashMap<>();
        Map<String, Object> metricMap = new HashMap<>();

        Iterator iterator = metricsEndpoint.listNames().getNames().iterator();
        Health health = healthEndpoint.health();

        boolean isCheck = check();
        if (isCheck) {
            // 에러 코드 유형 정의
            int errorCode = 404;
            return Health.down().withDetail("Error Code", errorCode).build();
        }

        while (iterator.hasNext()) {
            String metricName = iterator.next().toString();
            metricMap.put(metricName, metricsEndpoint.metric(metricName, null));
        }

        healthMap.put("diskSpace", health.getDetails().get("diskSpace"));
        healthMap.put("Metrics", metricMap);
        return Health.status("Health Check").withDetails(healthMap).build();
    }

    public boolean check() {
        // 헬스 체크 유형 정의
        return false;
    }
}
