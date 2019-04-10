DevOps 프로젝트  
--
 - 웹 어플리케이션을 Docker 를 통해 무중단 배포 서비스합니다. 
 - 구동 환경 : docker-ce, docker-compose, gradle
 
## 1. 스크립트 실행방법   
 - 스크립트 파일 :  [/spring-webservice-devops/scripts/devops.sh](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/devops.sh)  
 
        ./devops.sh [start | stop | restart | status | deploy]  
        
 - start : 컨테이너 환경 전체 실행  
 - stop : 컨테이너 환경 전체 중지  
 - restart : 컨테이너 환경 전체 재시작  
 - status : 컨테이너 환경 상태 확인  
 - deploy : 웹어플리케이션 무중단 배포  

## 2. 스크립트 실행 예제 
#### 예제1. 무중단 배포 스크립트 동작

 - 동작 순서  
   1. 소스코드 빌드  
   2. 도커 이미지 빌드  
   3. 웹 어플리케이션 컨테이너 Rolling restart : latest버전(nginx)을 제외한 모든 컨테이너
   4. Nginx HUP 시그널 송신   
~~~
./devops.sh deploy

Strartig Deploy Web App.
======[01] Build Java File....

BUILD SUCCESSFUL in 0s
3 actionable tasks: 3 up-to-date
======[02] Build Docker File...
Sending build context to Docker daemon  40.25MB
Step 1/7 : FROM java:8
 ---> d23bdf5b1b1b
Step 2/7 : COPY . /src
 ---> Using cache
 ---> f67aa180a54e
Step 3/7 : WORKDIR /src
 ---> Using cache
 ---> 240c6ab8b6d2
Step 4/7 : ADD ./libs/spring-webservice-devops-0.0.1-SNAPSHOT.jar webapp.jar
 ---> Using cache
 ---> 64ca0fe8d12f
Step 5/7 : ADD version.txt .
ADD failed: stat /var/lib/docker/tmp/docker-builder708043074/version.txt: no such file or directory
======[03] Rolling Restart WebApp docker service... [total : 3]
Restarting.... WebAPP Container : 1a89252596aa
1a89252596aa
Restarting.... WebAPP Container : 9357149cbe3d
9357149cbe3d
======[04] Nginx HUP Signal Transmit...

 All Container Deploy Complieted!
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                NAMES
1a89252596aa        webapp:1.0.0        "/bin/sh -c 'java -j…"   9 minutes ago       Up 12 seconds           8080/tcp             webapp-2
9357149cbe3d        webapp:1.0.0        "/bin/sh -c 'java -j…"   9 minutes ago       Up Less than a second   8080/tcp             webapp-1
ca1b7750a571        nginx:latest        "nginx -g 'daemon of…"   9 minutes ago       Up 6 minutes            0.0.0.0:80->80/tcp   nginx
~~~
 

#### 예제2. 컨테이너 환경 전체 중지    
~~~
./devops.sh stop

Stopping All WebApp Docker Service..
Stopping webapp-2 ... done
Stopping webapp-1 ... done
Stopping nginx    ... done
Removing webapp-2 ... done
Removing webapp-1 ... done
Removing nginx    ... done
Removing network build_devopsnet
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
~~~

#### 예제3. 컨테이너 환경 전체 실행   
~~~
./devops.sh start

Starting WebApp Docker Service...
Creating network "build_devopsnet" with the default driver
Creating webapp-2 ... done
Creating nginx    ... done
Creating webapp-1 ... done
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                NAMES
6a647513629e        webapp:latest       "/bin/sh -c 'java -D…"   1 second ago        Up Less than a second   8080/tcp             webapp-2
47b3270de39a        webapp:latest       "/bin/sh -c 'java -D…"   1 second ago        Up Less than a second   8080/tcp             webapp-1
96019716b29f        nginx:latest        "nginx -g 'daemon of…"   1 second ago        Up Less than a second   0.0.0.0:80->80/tcp   nginx
~~~

#### 예제4. 컨테이너 환경 전체 재시작  

~~~
./devops.sh restart

Restarting ALL WebApp Docker Service..
Restarting webapp-2 ... done
Restarting webapp-1 ... done
Restarting nginx    ... done
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                NAMES
6a647513629e        webapp:latest       "/bin/sh -c 'java -D…"   55 seconds ago      Up Less than a second   8080/tcp             webapp-2
47b3270de39a        webapp:latest       "/bin/sh -c 'java -D…"   55 seconds ago      Up Less than a second   8080/tcp             webapp-1
96019716b29f        nginx:latest        "nginx -g 'daemon of…"   55 seconds ago      Up 10 seconds           0.0.0.0:80->80/tcp   nginx

~~~

#### 예제5. Container scale in/out 방법  

    
 1. scale in  
    1. [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L1) 대상 컨테이너 서비스 제거
    2. [/spring-webservice-devops/nginx/conf/devops-nginx.conf](https://github.com/JungJinSu/spring-webservice-devops/blob/master/nginx/conf/devops-nginx.conf#L6) upstream 내에 대상 서버 정보 제거
    3. docker stop "대상 컨테이너 이름"  
    4. docker rm "대상 컨테이너 이름" 

 2. scale out  
    1. [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L1) 컨테이너 서비스 추가     
    2. [/spring-webservice-devops/nginx/conf/devops-nginx.conf](https://github.com/JungJinSu/spring-webservice-devops/blob/master/nginx/conf/devops-nginx.conf#L6)   upstream 서버 추가  
    3. ./devops.sh start 컨테이너 시작  
      
## 3. 요구사항 결과    

  - 웹 어플리케이션을 Docker 를 통해 서비스 하려합니다. 다음 요구사항에 부합하도록 설정, 빌드, 실행 스크립트를 구현해 주세요.  
  
  1. 웹 애플리케이션 예제  
    : [spring-boot-sample-web-ui](https://github.com/spring-projects/spring-boot/tree/v2.0.2.RELEASE/spring-boot-samples/spring-boot-sample-web-ui)
         
  2. build script는 gradle로 작성   
    : [/spring-webservice-devops/build.gradle](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build.gradle#L1)  
 
  3. 어플리케이션들은 모두 독립적인 Container 로 구성  
    : [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L1)
     
  4. 어플리케이션들의 Log 는 Host 에 file 로 적재  
    : [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L24)    
    : [/spring-webservice-devops/log](https://github.com/JungJinSu/spring-webservice-devops/tree/master/log)  
  
  5. Container scale in/out 가능해야 함  
    : [예제5. Container scale in/out 방법](https://github.com/JungJinSu/spring-webservice-devops#%EC%98%88%EC%A0%9C5-container-scale-inout-%EB%B0%A9%EB%B2%95)
  
  6. 웹서버는 Nginx 사용  
    : [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L5)  
 
  7. 웹서버는 Reverse proxy 80 port, Round robin 방식으로 설정  
    : [spring-webservice-devops/nginx/conf/devops-nginx.conf](https://github.com/JungJinSu/spring-webservice-devops/blob/master/nginx/conf/devops-nginx.conf#L6)  
    
  8.  무중단 배포 동작을 구현 (배포 방식에 제한 없음)  
    : [/spring-webservice-devops/scripts/devops.sh](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/devops.sh#L35)  
   
  9. 실행스크립트 개발언어는 bash/python/go 선택하여 작성  
    : [/spring-webservice-devops/scripts/devops.sh](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/devops.sh#L1)  
   
  10.  어플리케이션 REST API 추가  
     - [GET /health] Health check  
     - REST API 응답결과는 JSON Object 구현    
     : [/spring-webservice-devops/src/main/java/com/jjs/webservice/web/ui/mvc/HealthController.java](https://github.com/JungJinSu/spring-webservice-devops/blob/master/src/main/java/com/jjs/webservice/web/ui/mvc/HealthController.java)  
       
  11. README.md 파일에 프로젝트 실행 방법 명시 

 #### Todo List  
 
  1. scale in/out 으로 deploy 할 경우 rolling restart 컨테이터 이름 라벨 문제. -> count 개수가 아니라 컨테이너 이름 자체를 txt 파일로 w/r.
  2. auto scaling : 스케일 인/아웃 자동화 스크립트  