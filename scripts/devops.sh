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
}

stop() {
  echo
  echo "Stopping All WebApp Docker Service.."
  docker-compose -f $TARGETPATH/docker-compose.yml down
  docker ps
}

restart() {
  echo
  echo "Restarting ALL WebApp Docker Service.."
  docker-compose -f $TARGETPATH/docker-compose.yml restart
  docker ps
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
  docker build -f DockerfileWebApp -t webapp:latest .

  # Count Docker Services and Rolling restart
  SERVICECOUNT=$(docker ps | grep webapp* | wc -l | grep -o "[0-9]\+")
  echo "======[03] Rolling Restart WebApp docker service... [total : $SERVICECOUNT]"
  for ((i=1;i<$SERVICECOUNT+1;i++));
    do
      #FIXME: scale in/out  된 상태에서 해당 컨테이터이름라벨 문제발생. -> count 개수가 아니라 컨테이너 이름 자체를 txt 파일로 저장해야함. 
      echo "Restart.... webapp-$i "
      docker stop webapp-$i
      docker rm webapp-$i
      docker-compose -f docker-compose.yml up -d webapp-$i
  done
  
  # exec Nginx Dokcer Containner & Signal Trasnmit 
  echo "======[04] Nginx HUP Signal Transmit..."
  docker container exec nginx nginx -s reload
  echo " All Container Deploy Complieted!"
  docker ps 
  
  #echo "Checking Reloaded Nginx conf File..."
  #docker container exec nginx cat /etc/nginx/conf.d/default.conf
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
