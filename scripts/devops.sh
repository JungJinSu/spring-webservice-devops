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
  #docker build -f $TARGETPATH/DockerfileNginx -t nginx:devops .

  # restart on changed docker images.
  stop
  start
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
