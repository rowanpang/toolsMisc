#!/bin/sh
prog=$0
svr="$(dirname $prog)/synergys"
cli="$(dirname $prog)/synergyc"
if [ $HOSTNAME == "rowanInspur.lan" ];then
    echo "server $svr"
else
    echo "client $cli"
fi
