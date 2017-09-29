#!/bin/bash
function pr_err(){
    #31m,red
    echo -e "\033[1;31m" "$@" "\033[0m"
    exit -1
}

function ssCmdRunning(){
    [ "$(ps -e | grep $ssCmd)" ] && echo "yes"
}

function getCurProxyState(){
    [ -f $confFile ] && state="$(cat $confFile | awk '/proxyState:/ {print $2}')"
    if ! [ "$(ssCmdRunning)" ];then
	state="not running"
    fi

    echo $state
}

function checkTime(){
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

function gotworkDir(){
    local prog=$1
    local wDir
    [ -L $prog ] && wDir=$(dirname `readlink $prog`)
    wDir=$(dirname $prog)

    echo "${wDir}/"
}

function Usage(){
    echo "         -h:this help info"
    echo "--checkTime: do time check"
}

function argParser(){
    if [ -x /usr/bin/ss-local ];then
	ssCmd="ss-local"		#elf bin    recomend
    else
	ssCmd="sslocal"			#python version
    fi
    workDir=$(gotworkDir $0)
    confFile="${workDir}curConf.txt"

    while [ $# -gt 0 ];do
	case "$1" in
	    --checkTime)
		doTimeCheck=true ;;
	    --systemd)
		calledBySystemd=true;;
	    -h)
		Usage
		exit
	esac
	shift
    done
}

function update(){
    if [ "$calledBySystemd" ];then
	cmd="systemctl restart shadowsocks-rowan"
    else
	cmd=${workDir}ssUpdate.sh
    fi
    echo "update do:"$cmd
    $cmd
}

function main(){
    argParser $@		#at first

    local doUpdate="no"
    local ret="$(checkTime)"
    local curProxyState=$(getCurProxyState)

    if [ "$curProxyState" != "ok" ];then
	doUpdate="yes"
	cause="$ssCmd:$curProxyState"
    elif [ $doTimeCheck ];then
	if [ "do" == "$ret" ];then
	    doUpdate="yes"
	    cause="checkTime,time past,need do"
	else
	    doUpdate="no"
	    cause="checkTime,time ok not update"
	fi
    elif ! [ "$doTimeCheck" ];then
	doUpdate="yes"
	cause="not checkTime,just do update"
    else
	cause="dry run,not do update"
    fi

    echo $cause
    [ "$doUpdate" == "yes" ] && update
    return 0		    #if not,systemd will treat exit with error
}

main $@
