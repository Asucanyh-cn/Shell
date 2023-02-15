#!/bin/bash
wlan0ip=`sudo ifconfig wlan0|grep "inet "|awk '{print $2}'`
tun0ip=`sudo ifconfig tun0|grep "inet "|awk '{print $2}'`

#open sshd
startSshd(){
  cmd="sshd"
  echo "### $cmd ###"
  pkill $cmd
  if [ "$?" -eq "0" ];then
    sleep 1
    echo "[Note] Restarting $cmd."
  fi
      $cmd
    if [ "$?" -eq 0 ];then
      echo "[Note] $cmd start sucessfully!"
      sleep 1
      ps -eo pid,cmd,user|grep $cmd|grep -v grep|awk '{print "[Info]","PID:",$1,"USER:",$6}'
    else
      echo "[Note] Faild to start $cmd!"
    fi
}
#open nginx &php-fpm
startNginx(){
  cmd="nginx"
  echo "### $cmd ###"
  sudo pkill nginx
  if [ "$?" -eq "0" ];then
    sleep 1
    echo "[Note] Restarting nginx."
  fi
      sudo nginx
    if [ "$?" -eq 0 ];then
    echo "[Note] Nginx start sucessfully!"
    sleep 1
    sudo ps -eo pid,cmd,user|grep "nginx: master"|grep -v grep|awk '{print "[Info]","PID:",$1,"USER:",$6}'
  else
    echo "[Note] Faild to start nginx!"
  fi
}

#open syncthing
startSyncthing(){
  cmd="syncthing"
  echo "### $cmd ###"  
  pid=`ps -eo pid,cmd,user|grep syncthing|grep -v grep|awk '{print $1}'`
  if [ -n "$pid" ];then
    kill $pid
  fi
  if [ "$?" -eq "0" ];then
    sleep 1
    echo "[Note] Restarting syncthing."
  fi
        syncthing &>/dev/null & 
  if [ "$?" -eq 0 ];then
    echo "[Note] Syncthing start sucessfully!"
    sleep 1
    ps -eo pid,cmd,user|grep "$cmd"|grep -v grep |awk '{print "[Info]","PID:",$1," ","USER:",$3}'
  else
    echo "[Note] Faild to start syncthing!"
  fi
}
#open php-fpm
startPhp-fpm(){
  cmd="php-fpm"
  echo "### $cmd ###"
  sudo pkill php-fpm
  if [ "$?" -eq "0" ];then
      sleep 1
      echo "[Note] Restarting php-fpm."
  fi
        sudo $cmd -R
    if [ "$?" -eq 0 ];then
      echo "[Note] php-fpm start sucessfully!"
      sleep 1
    sudo ps -eo pid,cmd,user|grep "php-fpm: master"|grep -v grep|awk '{print "[Info]","PID:",$1,"USER:",$6}'
    else
      echo "[Note] Faild to start php-fpm!"
    fi
}

#main
case $1 in
  all)
  startSshd
  startNginx
  startPhp-fpm
  startSyncthing
    ;;
    1)
  startSshd
  ;;
    2)
  startNginx
  startPhp-fpm
  ;;
    3)
  startSyncthing
  ;;
  help)
  echo -e "[Note] \n1 sshd\n2 nginx & php-fpm\n3 syncthing"
  ;;
  *)
  echo "[!] invalid input"
  echo -e "[Note] \n1 sshd\n2 nginx & php-fpm\n3 syncthing"
esac