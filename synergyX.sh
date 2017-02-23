#!/bin/sh
prog=$0
svrName="rowanInspur.lan"

svr="$(dirname $prog)/synergys"
cli="$(dirname $prog)/synergyc $svrName"

if [ $HOSTNAME == $svrName ];then
    echo "server $svr"
    exec $svr
else
    echo "client $cli"
    exec $cli
    #for synergyc disable all xkbmap,just use the server config.
    /usr/bin/setxkbmap -option -option
fi
