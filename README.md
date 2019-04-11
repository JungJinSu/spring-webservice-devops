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
   3. 웹 어플리케이션 컨테이너 Rolling restart. (nginx-proxy를 제외한 모든 컨테이너)   
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

#### 예제5. Container scale in/out 
 - [docker-compose scale](https://docs.docker.com/compose/reference/scale/) 옵션 사용 
#### 1. scale out  
      docker ps
      CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                NAMES
      2ff1f4b0f39c        jwilder/nginx-proxy   "/app/docker-entrypo…"   2 hours ago         Up 2 hours          0.0.0.0:80->80/tcp   nginx-proxy
      fbc82845a3cc        webapp:1.0.0          "/bin/sh -c 'java -j…"   2 hours ago         Up 2 hours          8080/tcp             build_webapp_1
      
      docker-compose -f docker-compose.yml up -d --scale webapp=3
      Starting build_webapp_1 ...
      Starting build_webapp_1 ... done
      Creating build_webapp_2 ... done
      Creating build_webapp_3 ... done
      
      docker ps
      CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                NAMES
      a84a153ae26c        webapp:1.0.0          "/bin/sh -c 'java -j…"   7 seconds ago       Up 5 seconds        8080/tcp             build_webapp_2
      f1189f50c54d        webapp:1.0.0          "/bin/sh -c 'java -j…"   7 seconds ago       Up 5 seconds        8080/tcp             build_webapp_3
      2ff1f4b0f39c        jwilder/nginx-proxy   "/app/docker-entrypo…"   2 hours ago         Up 2 hours          0.0.0.0:80->80/tcp   nginx-proxy
      fbc82845a3cc        webapp:1.0.0          "/bin/sh -c 'java -j…"   2 hours ago         Up 2 hours          8080/tcp             build_webapp_1
#### 2. scale in
    
    docker-compose -f docker-compose.yml up -d --scale webapp=1
    Stopping and removing build_webapp_2 ...
    Stopping and removing build_webapp_2 ... done
    Stopping and removing build_webapp_3 ... done
    Starting build_webapp_1              ... done
    
    docker ps
    CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                NAMES
    2ff1f4b0f39c        jwilder/nginx-proxy   "/app/docker-entrypo…"   2 hours ago         Up 2 hours          0.0.0.0:80->80/tcp   nginx-proxy
    fbc82845a3cc        webapp:1.0.0          "/bin/sh -c 'java -j…"   2 hours ago         Up 2 hours          8080/tcp             build_webapp_1
    
## 3. 요구사항 결과    

  - 웹 어플리케이션을 Docker 를 통해 서비스 하려합니다. 다음 요구사항에 부합하도록 설정, 빌드, 실행 스크립트를 구현해 주세요.  
  
  1. 웹 애플리케이션 예제  
    : [spring-boot-sample-web-ui](https://github.com/spring-projects/spring-boot/tree/v2.0.2.RELEASE/spring-boot-samples/spring-boot-sample-web-ui)
         
  2. build script는 gradle로 작성   
    : [/spring-webservice-devops/build.gradle](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build.gradle#L1)  
 
  3. 어플리케이션들은 모두 독립적인 Container 로 구성  
    : [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L1)
     
  4. 어플리케이션들의 Log 는 Host 에 file 로 적재  
    : [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L1)    
    : [/spring-webservice-devops/logs](https://github.com/JungJinSu/spring-webservice-devops/tree/master/logs)  
  
  5. Container scale in/out 가능해야 함  
    : [예제5. Container scale in/out 방법](https://github.com/JungJinSu/spring-webservice-devops#%EC%98%88%EC%A0%9C5-container-scale-inout)
  
  6. 웹서버는 Nginx 사용  
    : [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L1)  
 
  7. 웹서버는 Reverse proxy 80 port, Round robin 방식으로 설정  
    : [/spring-webservice-devops/build/docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml#L1)  
    : nginx-proxy Default Round robin LB.   
    
  8.  무중단 배포 동작을 구현 (배포 방식에 제한 없음)  
    : [/spring-webservice-devops/scripts/devops.sh](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/devops.sh#L35)  
   
  9. 실행스크립트 개발언어는 bash/python/go 선택하여 작성  
    : [/spring-webservice-devops/scripts/devops.sh](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/devops.sh#L1)  
   
  10.  어플리케이션 REST API 추가  
     - [GET /health] Health check  
     - REST API 응답결과는 JSON Object 구현    
     : [/spring-webservice-devops/src/main/java/com/jjs/webservice/web/ui/mvc/HealthController.java](https://github.com/JungJinSu/spring-webservice-devops/blob/master/src/main/java/com/jjs/webservice/web/ui/mvc/HealthController.java)  
       
  11. README.md 파일에 프로젝트 실행 방법 명시 

 ## DevOps 과정에 고민한 부분  
  1. Auto Scaling : 스케일 인/아웃 자동화 방법     
     - [docker-compose scale](https://docs.docker.com/compose/reference/scale/) 사용하면 되겟다. okay...
     - 다음 작업은?  
     - nginx proxy 설정파일 업데이트 자동화 (쉘로 어떻게 짜면 될 것 같다.)
     - docker socket API 통신 (이것도 아름아름 찾아서 하면 될 것 같다...)
     - 음... 생각보다 걱정되는 부분이 많아짐.  
     - [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) 를 뒤늦게 발견.
     - 고민과 걱정 동시 해결! 
     - **Thanks to jason wilder!**  
      
  2. Non-Disruptive Deploy :  무중단 배포시 서비스 상황 
     - non-stop request 상황에서도 무중단 배포 서비스 유지  
     - 컨테이너를 Rolling restart 하자. 
     - nginx는 DownTime이 없어야 함으로, [nginx signal](http://nginx.org/en/docs/control.html)로 설정파일을 업데이트 하자.  
     - nginx 설정 파일 수정을 어떻게 자동화 할것인가? -> auto scale 과 똑같은 문제 발생 
     - [초라한 signal 명령](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/devops.sh#L78) 한 줄은 지우고..  
     - 다시한번, **Thanks to jason wilder!** 
     
   - 남은 작업 : printenv -> HOSTNAME(container id) health check 추가하기