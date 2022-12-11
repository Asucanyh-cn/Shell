#!/bin/bash
nginx
if [ $0 -eq "0" ];then
echo "Note:  nginx start successfully!"
fi
php-fpm -R
if [ $0 -eq "0" ];then
echo "Note: php-fpm start successfully!"
fi
node $PWD/daemon/app.js

