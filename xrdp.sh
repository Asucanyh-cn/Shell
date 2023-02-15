#!/bin/bash
start(){
  sudo rm -rf /var/run/xrdp/xrdp-sesman.pid
  sudo rm -rf /var/run/xrdp/xrdp.pid
  sudo service xrdp restart
}
stop(){
  sudo service xrdp stop
}
case $1 in
  "start")
    start
  ;;
  "stop")
    stop
  ;;
  *)
  echo "[!] invalid input"
esac