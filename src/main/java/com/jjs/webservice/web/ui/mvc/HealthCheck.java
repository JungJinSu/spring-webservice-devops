package com.jjs.webservice.web.ui.mvc;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthEndpoint;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.boot.actuate.metrics.MetricsEndpoint;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class HealthCheck implements HealthIndicator {


    private static Logger logger = LogManager.getLogger(HealthCheck.class);

    @Autowired
    private MetricsEndpoint metricsEndpoint;

    @Autowired
    private HealthEndpoint healthEndpoint;

    @Value("#{systemEnvironment['HOSTNAME']}")
    private String hostname;

    // Actuator 에서 제공하는 Endpoint 로 Custom HealthCheck
    @Override
    public Health health() {

        logger.info("HealthChecking... ");
        Map<String, Object> healthMap = new HashMap<>();
        Map<String, Object> metricMap = new HashMap<>();
        Map<String, Object> leastMetricMap = new HashMap<>();

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

        //너무 많은 정보.. 필요한것 몇개만.
        //healthMap.put("Metrics", metricMap);

        // GC
        leastMetricMap.put("jvm.gc.memory.allocated",metricMap.get("jvm.gc.memory.allocated"));
        leastMetricMap.put("jvm.gc.pause",metricMap.get("jvm.gc.pause"));
        leastMetricMap.put("jvm.buffer.memory.used",metricMap.get("jvm.buffer.memory.used"));
        leastMetricMap.put("jvm.gc.max.data.size",metricMap.get("jvm.gc.max.data.size"));

        // 하드웨어 & 시스템 자원
        leastMetricMap.put("jvm.memory.max",metricMap.get("jvm.memory.max"));
        leastMetricMap.put("jvm.memory.used",metricMap.get("jvm.memory.used"));
        leastMetricMap.put("system.cpu.count",metricMap.get("system.cpu.count"));
        leastMetricMap.put("system.cpu.usage",metricMap.get("system.cpu.usage"));
        leastMetricMap.put("process.cpu.usage",metricMap.get("process.cpu.usage"));
        leastMetricMap.put("process.uptime",metricMap.get("process.uptime"));

        healthMap.put("Metrics", leastMetricMap);
        healthMap.put("diskSpace", health.getDetails().get("diskSpace"));
        healthMap.put("Container ID", hostname);
        return Health.status("Health Check").withDetails(healthMap).build();
    }

    public boolean check() {
        // 헬스 체크 유형 정의
        return false;
    }
}
