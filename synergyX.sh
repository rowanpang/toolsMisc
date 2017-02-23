#!/bin/sh
prog=$0
svrName="rowanInspur.lan"

svr="$(dirname $prog)/synergys"
cli="$(dirname $prog)/synergyc $svrName"

if [ $HOSTNAME == $svrName ];then
    echo "server $svr"
    $svr
else
    echo "client $cli"
    /usr/bin/setxkbmap -option -option
    $cli
    #for synergyc disable all xkbmap,just use the server config.
fi
