#!/bin/bash
function pr_err(){
    #31m,red
    echo -e "\033[1;31m" "$@" "\033[0m"
    exit -1
}

function parserPwdIp(){
    pwd=$1
    ip=$2
}

function parserConfs(){
    method=$1
    pwdIp=$2
    port=$3
    IFS='@'
    parserPwdIp $pwdIp
}

function updateConfigFile(){
    local server=`echo $1`
    local cmd=`echo $2`

    echo "stamp: `date +%Y%m%d" "%_H`" > $confFile
    echo "server: $server" >> $confFile
    echo "cmd: $cmd" >> $confFile
}

function updateProxyState(){
    local state=`echo $1`
    echo "proxyState: $state" >> $confFile
}

function starfromQR(){
    local qridx=${1}
    local qrimgWeb=${qrid}xxoo.png
    local qrimglocal=${workDir}${qridx}.png
    local quiet="-q"
    local duration="10s"
    local svrHostName="rowanInspur"
    echo -e "\033[1;31m""update to $tmpIndex""\033[0m"
    local remoteHost="get.ishadow.website/"
    local remoteHost="ss.ishadowx.net/"
    timeout $duration wget $quiet -O ${qrimglocal} http://${remoteHost}/img/qr/${qrimgWeb}
    if ! [ -s ${qrimglocal} ];then
	export http_proxy="127.0.0.1:8087"
	timeout $duration wget $quiet -O ${qrimglocal} http://${remoteHost}/img/qr/${qrimgWeb}
	unset http_proxy
	if ! [ -s ${qrimglocal} ];then
	    echo -e "\033[1;31m""$(date):next update download img ${qrimglocal} error!""\033[0m"
	    echo -e "\033[1;31m""$(date):next update download img ${qrimglocal} error!""\033[0m" >> $confFile
	    exit -1
	fi
    fi

    info=$(zbarimg $quiet ${qrimglocal})
    base64=${info#QR-Code:ss://}
    confs=$(echo $base64 | base64 -d)
    oifs=$IFS
    IFS=':'
    parserConfs $confs
    IFS="$oifs"
    bindip="127.0.0.1"
    isRowanNet=`ip a s | grep 'inet ' | grep '192.168\.1\.'`
    if [ `expr match "$(hostname)" "$svrHostName"` != 0 ] && [ "$isRowanNet" ];then
	bindip='0.0.0.0'
    fi

    if [ "$ssCmd" == "ss-local" ];then
	cmd="$ssCmd -s $ip -p $port -k $pwd -m $method -b $bindip -l 1080
	    -f ${workDir}ss.pid"

	if [ "$(ssCmdRunning)" ];then
	    kill -9 `pidof $ssCmd`
	fi

    else
	cmd="$ssCmd $quiet -d restart -s $ip -p $port -k $pwd -m $method    \
	    -b $bindip -l 1080						 \
	    --pid-file ${workDir}ss.pid --log-file ${workDir}ss.log"
    fi

    updateConfigFile "$qridx" "$cmd"

    $cmd
}

function proxyOK(){
    `timeout 15 curl --insecure --silent --proxy socks5h://127.0.0.1:1080 https://twitter.com > /dev/null`
    ret=$?
    local state=""
    [ $ret -eq 0 ] && state="ok" || state="ng"

    updateProxyState $state
    echo $state
}


function getCurServer(){
    [ -f $confFile ] && echo "$(cat $confFile | awk '/server:/ {print $2}')"
}

function getCurProxyState(){
    [ -f $confFile ] && echo "$(cat $confFile | awk '/proxyState:/ {print $2}')"
}

function ssCmdRunning(){
    [ "$(ps -e | grep $ssCmd)" ] && echo "yes"
}

function checkTime(){
    if ! [ "$(ssCmdRunning)" ];then
	echo "do"
	return
    fi

    local curStamp=`date +%Y%m%d" "%_H`
    local curDate=`echo $curStamp | awk '{print $1}'`
    local curSlice=`echo $curStamp | awk '{print $2}'`
    let curSlice="$curSlice"/6

    local lastSlice
    local lastDate

    if [ -f $confFile ];then
	lastDate=`cat $confFile | awk '/stamp:/ {print $2}'`
    fi

    if [ "$curDate" == "$lastDate" ];then
	if [ -f $confFile ];then
	    lastSlice=`cat $confFile | awk '/stamp:/ {print $3}'`
	fi
	[ $lastSlice ] || lastSlice=0
	let lastSlice="$lastSlice"/6
	[ $lastSlice == $curSlice ] && echo "same time slice" || echo "do"
    else
	echo "do"
    fi
}

function update(){
    local needCheck="yes"
    for co in us sg jp;do
	for index in a b c;do
	    tmpIndex="${co}${index}"
	    if [ "$specifyServer" ];then
		tmpIndex=${specifyServer%.*}
		[ "$curConfigServer" == "$tmpIndex" ] && pr_err "same as cur config"
		needCheck="no"
	    fi

	    #if [ "$curConfigServer" == "$tmpIndex" ];then #circle server?
		#continue
	    #fi

	    starfromQR $tmpIndex

	    if [ "$needCheck" != "no" ];then
		[ "$(proxyOK)" == "ok" ] && break 2 || echo "---proxy $tmpIndex check ng,next---"
	    else
		break 2
	    fi
	done
    done
}

function gotworkDir(){
    local prog=$1
    local wDir
    [ -L $prog ] && wDir=$(dirname `readlink $prog`)
    wDir=$(dirname $prog)

    echo "${wDir}/"
}

function Usage(){
    echo "      -h:this help info"
    echo "--server: specify Server to connect "
    echo "--checkTime: do time check"
}

function argParser(){
    workDir=$(gotworkDir $0)
    confFile="${workDir}curConf.txt"
    curConfigServer=$(getCurServer)
    curProxyState=$(getCurProxyState)

    if [ -x /usr/bin/ss-local ];then
	ssCmd="ss-local"		#elf bin    recomend
    else
	ssCmd="sslocal"			#python version
    fi

    echo -e "\033[1;31m""curUsed: $curConfigServer""\033[0m"

    while [ $# -gt 0 ];do
	case "$1" in
	    --server)
		specifyServer=$2
		shift
		;;
	    --checkTime)
		doTimeCheck=true ;;
	    -h)
		Usage
		exit
	esac
	shift
    done
}

function main(){
    argParser $@		#at first

    local doUpdate=""
    local ret="$(checkTime)"

    if [ "$curProxyState" != "ok" ] || [ ! "$doTimeCheck" ] || ( [ $doTimeCheck ] && [ "do" == "$ret" ] );then
	doUpdate="yes"
    else
	echo "$ret"
    fi

    [ "$doUpdate" == "yes" ] && update

}

main $@
