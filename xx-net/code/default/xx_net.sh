#!/bin/sh
#
# xx_net init script
#

### BEGIN INIT INFO
# Provides:          xx_net
# Required-Start:    $syslog
# Required-Stop:     $syslog
# Should-Start:      $local_fs
# Should-Stop:       $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Monitor for xx_net activity
### END INIT INFO

# **NOTE** bash will exit immediately if any command exits with non-zero.
set -e

PACKAGE_NAME=xx_net
PACKAGE_DESC="xx_net proxy server"
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:${PATH}
if python -V | grep -q "Python 3" ;then
    PYTHON="/usr/bin/python2"
else
    PYTHON="python"
fi
if [ -L $0 ];then
	PACKAGE_PATH="$(dirname $(readlink -n $0))/../"
else
	PACKAGE_PATH="../"
fi

PACKAGE_VER_FILE="${PACKAGE_PATH}version.txt"
PACKAGE_VER="default"

if [ -f "${PACKAGE_VER_FILE}" ];then
	PACKAGE_VER=$(cat $PACKAGE_VER_FILE)
fi

start() {
    echo -n "Starting ${PACKAGE_DESC}: "
    if hash python2 2>/dev/null; then
        #nohup "${PYTHON}" launcher/start.py 2>&1 | /usr/bin/logger -t ${PACKAGE_NAME} &
        #nohup "${PYTHON}" launcher/start.py >/dev/null 2>&1 &
        nohup "${PYTHON}" ${PACKAGE_PATH}${PACKAGE_VER}/launcher/start.py >/dev/null 2>&1 &
    fi
    echo "${PACKAGE_NAME}."
}

stop() {
    echo -n "Stopping ${PACKAGE_DESC}: "
    kill -9 `ps aux | grep "${PACKAGE_VER}/launcher/start.py" | grep -v grep | awk '{print $2}'` || true
    echo "${PACKAGE_NAME}."
}

status() {
	pid="PID`ps aux | grep "${PACKAGE_VER}/launcher/start.py" | grep -v grep | awk '{print $2}'`"
	if [ $pid == "PID" ];then
		echo "xx-net stoped"
	else
		echo "xx-net running,pid: ${pid##"PID"}"
	fi
}
	

restart() {
    stop
    sleep 1
    start
}

usage() {
    N=$(basename "$0")
    echo "Usage: [sudo] $N {start|stop|restart|status}" >&2
    exit 1
}

if [ "$(id -u)" != "0" ]; then
    echo "please use sudo to run ${PACKAGE_NAME}"
    exit 0
fi

# `readlink -f` won't work on Mac, this hack should work on all systems.
cd $("${PYTHON}" -c "import os; print os.path.dirname(os.path.realpath('$0'))")

case "$1" in
    # If no arg is given, start the goagent.
    # If arg `start` is given, also start goagent.
    '' | start)
        start
        ;;
    stop)
        stop
        ;;
    #reload)
    restart | force-reload)
        restart
        ;;
	status)
		status
		;;
    *)
        usage
        ;;
esac

exit 0
}
