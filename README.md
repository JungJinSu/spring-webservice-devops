DevOps 프로젝트  
---
##### 프로젝트  설치 및 실행 방법 
   - 설치 환경 준비  
    - centOS 7.1  
    - docker-ce, docker-compose, gradle 
     - 설치가 되어 있지 않은 경우 다음 스크립트 실행 : [install.sh](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/install.sh)  
   - 소스코드 pull  
   - <U>scripts 폴더로 이동</U>하여 [devops.sh](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/devops.sh) 스크립트 실행  
   ~~~
   ./devops.sh [start | stop | restart | deploy] 
     - start : 컨테이너 환경 전체 실행
     - stop : 컨테이너 환경 전체 중지 
     - restart : 컨테이너 환경 전체 재시작 
     - deploy : 웹어플리케이션 무중단 배포
   ~~~
     
### 데모 시나리오   
#### 1. Container scale in/out 방법   
    scale in  
    [01] docker-compose.yml  컨테이너 서비스 설정 제거
    [02] devops-nginx.conf   upstream 해당 서버 제거
    [03] docker stop [컨테이너 이름]
    [04] docker rm [컨테이너 이름]
    
    scale out  
    [01] docker-compose.yml  컨테이너 서비스 추가
      - 컨테이너 이름 규칙 : webapp-(숫자)  
    [02] devops-nginx.conf   upstream 서버 추가 
    [03] devops.sh start     새로 추가한 컨테이너 시작


#### 2. 무중단 배포 스크립트 동작
    
    ./devops.sh deploy  
    
    [01] 소스코드 빌드
    [02] 도커 이미지 빌드 
    [03] 컨테이너 Rolling restart 


---
### 요구사항 결과물    

  - 웹 어플리케이션을 Docker 를 통해 서비스 하려합니다. 다음 요구사항에 부합하도록 설정, 빌드, 실행 스크립트를 구현해 주세요.  
  
  1. 웹 애플리케이션 예제  
    : [spring-boot-sample-web-ui](https://github.com/spring-projects/spring-boot/tree/v2.0.2.RELEASE/spring-boot-samples/spring-boot-sample-web-ui)
         
  2. build script는 gradle로 작성   
    : [build.gradle](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build.gradle)  
 
  3. 어플리케이션들은 모두 독립적인 Container 로 구성  
    : [docker-compose.yml](https://github.com/JungJinSu/spring-webservice-devops/blob/master/build/docker-compose.yml)
     
  4. 어플리케이션들의 Log 는 Host 에 file 로 적재  
    : [webapp.log](https://github.com/JungJinSu/spring-webservice-devops/tree/master/log/webapp01)  
    
  5. Container scale in/out 가능해야 함  
  
  6. 웹서버는 Nginx 사용  
 
  7. 웹서버는 Reverse proxy 80 port, Round robin 방식으로 설정  
    : [devops-nginx.conf](https://github.com/JungJinSu/spring-webservice-devops/blob/master/nginx/conf/devops-nginx.conf)  
    
  8.  무중단 배포 동작을 구현 (배포 방식에 제한 없음)  
    : [devops.sh](https://github.com/JungJinSu/spring-webservice-devops/blob/master/scripts/devops.sh)  
   
  9. 실행스크립트 개발언어는 bash/python/go 선택하여 작성  
   
  10.  어플리케이션 REST API 추가  
     - [GET /health] Health check  
     - REST API 응답결과는 JSON Object 구현    
     : [HealthController.java](https://github.com/JungJinSu/spring-webservice-devops/blob/master/src/main/java/com/jjs/webservice/web/ui/mvc/HealthController.java)  
       
  11. README.md 파일에 프로젝트 실행 방법 명시 


 ##### Todo List
  1. scale in/out  된 상태에서 해당 컨테이터 이름 라벨 문제. -> count 개수가 아니라 컨테이너 이름 자체를 txt 파일로 저장해야함.
