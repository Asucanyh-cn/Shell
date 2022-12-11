#!/bin/bash
nohup /data/data/com.termux/files/usr/bin/frpc \
-c /data/data/com.termux/files/home/.frpc/frpc.ini \
&>$HOME/.frpc/frpc.log &
