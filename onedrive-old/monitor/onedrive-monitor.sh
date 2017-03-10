#!/bin/bash
#dameon to monitor onedrive-d connect status,if connect gone then restart it
#/usr/local/python3.5.1/bin/onedrive-d start
#sleep 30m
while [ 0 ];do
	count_num=`ss -r --tcp | grep -c '1drv.'`
	if ! [ $count_num -gt 0 ];then
		echo "onedrive connect lost";
		/usr/local/python3.5.1/bin/onedrive-d restart
		sleep 30m
	else
		echo "connection ok num $count_num";
	fi
	sleep 2m 
	echo;
done
