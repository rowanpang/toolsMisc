#!/bin/sh
prog=$0
svrName="rowanInspur.lan"
svrPort=24800
ipBridge0=`ip a s bridge0 | grep 'inet\s\+' | awk '{print $2}' | cut -d '/' -f 1`
if [ $ipBridge0 ];then
    addr=$ipBridge0
else
    addr='0.0.0.0'
fi

svrCmd="$(dirname $prog)/synergys --address $addr"
cliCmd="$(dirname $prog)/synergyc $svrName"

#by startup the network may not connected.

if [ $HOSTNAME == $svrName ];then
    $svrCmd
else
    while [ "yes" ];do
	tcping $svrName $svrPort -q -t 1 && break
	sleep 1
    done

    $cliCmd
    /usr/bin/setxkbmap -option -option	    #for synergyc disable all xkbmap,just use the server config.
fi
