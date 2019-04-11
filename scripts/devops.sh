#! /usr/bin/env bash
cd ../build
TARGETPATH=$(pwd)
cd ../
BASEPATH=$(pwd)


start() {
  echo
  echo "Starting WebApp Docker Service..."
  docker-compose -f $TARGETPATH/docker-compose.yml up -d 
  docker ps
  docker ps -a -q > $TARGETPATH/docker-scale-member.txt
}

stop() {
  echo
  echo "Stopping All WebApp Docker Service.."
  docker-compose -f $TARGETPATH/docker-compose.yml down
  docker ps
  docker ps -a -q > $TARGETPATH/docker-scale-member.txt
}

restart() {
  echo
  echo "Restarting ALL WebApp Docker Service.."
  docker-compose -f $TARGETPATH/docker-compose.yml restart
  docker ps
  docker ps -a -q > $TARGETPATH/docker-scale-member.txt
}

status() {
  echo 
  echo "Status Docer Services..."
  docker ps
}

deploy() {
  echo
  echo "Strartig Deploy Web App."

  echo "======[01] Build Java File...."
  gradle build -b $BASEPATH/build.gradle

  echo "======[02] Build Docker File... "
  cd $TARGETPATH
  version=`cat DockerBuildVersion.txt`
  docker build -f DockerfileWebApp -t webapp:$version .

  # Nginx 가 구동중이지 않은 경우
  NGINXCOUNT=$(docker ps -q -f "name=nginx-proxy"| wc -l | grep -o "[0-9]\+")
  
  if [ ${NGINXCOUNT} = 0 ];
  then
    echo 
    echo "==============Init All Server Starting ==================="
    # 초기 배포인 경우 전체 서버 구동 
    docker-compose -f docker-compose.yml up -d
    # Container id Store.  
    docker ps -a -q > docker-scale-member.txt
    exit 0
  fi

  # Container id Restore => Scale 된 경우id 변동이 생김. 
  docker ps -a -q > docker-scale-member.txt
  
  # docker-scale-member.txt 파일 기준으로 Rolling Restart. Nginx 제외.    
  WebAppContainerScale=$(cat docker-scale-member.txt | wc -l | grep -o "[0-9]\+")
  NGINXCONTAINERID=$(docker ps -q -f "name=nginx-proxy")
  echo "======[03] Rolling Restart WebApp docker service... [total : $WebAppContainerScale]"
  cat docker-scale-member.txt |\
  while read line
    do
     if ! [ $NGINXCONTAINERID == $line ];then
        echo "Restarting.... WebAPP Container : $line"
        docker restart $line
     fi
  done
  
  #docker container exec nginx nginx -s reload
  echo
  echo " All Container Deploy Complieted!"
  docker ps 
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
  deploy)
    deploy
    ;;
*)
  echo "Usage: $0 {start | stop | restart | status | deploy}"
esac
exit 0
