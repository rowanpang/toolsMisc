#!/bin/sh
prog=$0
svrName="rowanInspur.lan"
svrPort=24800
isRowanNet=`ip a s | grep 'inet ' | grep '192\.168\.1\.'`
deflink=`ip route | grep default | sed 's/^.*dev //' | awk '{print $1}'`

if [ -z $deflink ];then
    echo "synergyX no deflink!!!!"
    exit
fi

ipdeflink=`ip a s $deflink | grep 'inet\s\+' | awk '{print $2}' | cut -d '/' -f 1`
if [ "$isRowanNet" ];then
    addr='0.0.0.0'
else
    #exit
    addr=$ipdeflink
fi

svrCmd="$(dirname $prog)/synergys --address $addr"
svrCmd="/usr/bin/synergys --address $addr --enable-drag-drop"
svrCmd="/usr/bin/synergys --address $addr "	#prevent linux arrow abnormal
cliCmd="$(dirname $prog)/synergyc $svrName"

#by startup the network may not connected.
if [ ${HOSTNAME%.*} == ${svrName%.*} ];then
    $svrCmd
else
    while [ "yes" ];do
	tcping $svrName $svrPort -q -t 1 && break
	sleep 1
    done

    $cliCmd
    /usr/bin/setxkbmap -option -option	    #for synergyc disable all xkbmap,just use the server config.
fi
