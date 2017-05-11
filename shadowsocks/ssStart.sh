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

    echo "stamp: `date +%_H`" > $confFile			  
    echo "server: $server" >> $confFile			    
    echo "cmd: $cmd" >> $confFile			   
}

function starfromQR(){
    local qrimg=$1
    local qrimgfull=${workDir}${qrimg}
    local quiet="-q"
    local duration="10s"
    local svrHostName="rowanInspur"
    echo "current $tmpFile"
    local remoteHost="get.ishadow.website/"
    timeout $duration wget $quiet -O ${qrimgfull} http://${remoteHost}/img/qr/${qrimg}
    if ! [ -s ${qrimgfull} ];then
	export http_proxy="127.0.0.1:8087"
	timeout $duration wget $quiet -O ${qrimgfull} http://${remoteHost}/img/qr/${qrimg}
	unset http_proxy
	if ! [ -s ${qrimgfull} ];then
	    echo -e "\033[1;31m""next update download img ${qrimgfull} error!""\033[0m" 
	    echo -e "\033[1;31m""next update download img ${qrimgfull} error!""\033[0m" >> $confFile
	    exit -1
	fi
    fi

    info=$(zbarimg $quiet ${qrimgfull})
    base64=${info#QR-Code:ss://}
    confs=$(echo $base64 | base64 -d)
    oifs=$IFS
    IFS=':'
    parserConfs $confs
    IFS="$oifs"
    bindip="127.0.0.1"
    [ `expr match "$(hostname)" "$svrHostName"` != 0 ] && bindip="0.0.0.0"

    cmd="sslocal $quiet -d restart -s $ip -p $port -k $pwd -m $method    \
	    -b $bindip -l 1080						 \
	    --pid-file ${workDir}ss.pid --log-file ${workDir}ss.log"

    updateConfigFile "$qrimg" "$cmd"

    $cmd
}

function checkOk(){
    `timeout 15 curl --insecure --silent --proxy socks5h://127.0.0.1:1080 https://twitter.com > /dev/null`
    ret=$?
    [ $ret -eq 0 ] && echo "ok" || echo "ng"
}


function getCurServer(){
    [ -f $confFile ] && echo "$(cat $confFile | awk '/server:/ {print $2}')"
}

function checkTime(){
    if ! [ "$(ps -e | grep sslocal)" ];then
	echo "do" 
	return
    fi

    local curSlice=`date +%_H`
    let curSlice="$curSlice"/6

    local lastSlice
    if [ -f $confFile ];then
	lastSlice=`cat $confFile | awk '/stamp:/ {print $2}'`
    fi
    [ $lastSlice ] || lastSlice=0
    let lastSlice="$lastSlice"/6
    [ $lastSlice == $curSlice ] || echo "do"
}

function update(){
    local needCheck="yes"
    for co in sg us jp;do
	for index in {a..c};do
	    tmpFile="${co}${index}.png"
	    if [ "$specifyServer" ];then
		tmpFile=${specifyServer%.*}.png
		[ "$curConfigServer" == "$tmpFile" ] && pr_err "same as cur config"
		needCheck="no"
	    fi
	    starfromQR $tmpFile
	    if [ "$needCheck" != "no" ];then
		[ "$(checkOk)" == "ok" ] && break 2 || echo "---proxy $tmpFile ng,next---"
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

function argParser(){
    workDir=$(gotworkDir $0)
    confFile="${workDir}curConf.txt"
    curConfigServer=$(getCurServer)

    while [ $# -gt 0 ];do
	case "$1" in
	    --server)
		specifyServer=$2
		shift
		;;
	    --checkTime)
		doSliceCheck=true ;;
	esac
	shift
    done
}


    
function main(){
    argParser $@

    if [ "$curConfigServer" == "jpc.png" ];then		    #treate as no useful server.
	return
    fi

    if [ $doSliceCheck ];then
	local doUpdate=$(checkTime)
	[ "$doUpdate" == "do" ] && update || echo "same time slice,exit"
    else
	update
    fi
}

main $@
