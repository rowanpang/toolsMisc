#!/bin/sh
prog=$0
svrName="rowanInspur.lan"
svrPort=24800

svrCmd="$(dirname $prog)/synergys"
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
