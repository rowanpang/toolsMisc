#!/bin/bash

PATH=PATH=/sbin:/bin:/usr/sbin:/usr/bin

fstart="/root/myNut/iWk/ipa.start.txt"
fstop="/root/myNut/iWk/ipa.stop.txt"

if [ -f $fstart ];then
    systemctl start firewalld
    rm $fstart
elif [ -f $fstop ];then
    systemctl stop firewalld
    rm $fstop
fi
