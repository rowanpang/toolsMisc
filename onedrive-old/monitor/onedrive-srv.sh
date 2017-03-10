#!/bin/bash

# chkconfig: 345 56 50
# description: xinetd is a powerful replacement for inetd. \
#          xinetd has access control mechanisms, extensive \
#              logging capabilities, the ability to make services \
#              available based on time, and can place \
#              limits on the number of servers that can be started, \
#              among other things.  

. /etc/init.d/functions

prog="onedrive-monitor.sh"
pidfile="/var/run/onedrive-srv.pid"

start(){
	echo -n $"Starting $prog: "
	/usr/local/python3.5.1/bin/onedrive-monitor.sh >/dev/null 2>&1 </dev/null &
	touch $pidfile
	echo `pidof $prog -x`>$pidfile
	success
	echo
}

stop(){
	echo -n $"Stoping $prog: "
	killproc -p $pidfile $prog

	echo
	/usr/local/python3.5.1/bin/onedrive-d stop
}


case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	status)
		status -p $pidfile $prog
		;;
	*)
		echo $"Usage: $0 {start|stop|status}"
esac

exit 0
