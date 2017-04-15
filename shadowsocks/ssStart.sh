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

function starfromQR(){
    local qrimg=$1
    local qrimgfull=${workDir}${qrimg}
    local quiet="-q"
    local duration="10s"
    local svrHostName="rowanInspur"
    timeout $duration wget $quiet -O ${qrimgfull} http://xyz.ishadow.online/img/qr/${qrimg}
    if ! [ -s ${qrimgfull} ];then
	export http_proxy="127.0.0.1:8087"
	timeout $duration wget $quiet -O ${qrimgfull} http://xyz.ishadow.online/img/qr/${qrimg}
	unset http_proxy
	if ! [ -s ${qrimgfull} ];then
	    echo -e "\033[1;31m" "next update download img ${qrimgfull} error!" "\033[0m" >> $curConf
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
    bindip="localhost"
    [ `expr match "$(hostname)" "$(svrHostName)"` != 0 ] && bindip="0.0.0.0"

    cmd="sslocal $quiet -d restart -s $ip -p $port -k $pwd -m $method    \
	    -b $bindip -l 1080						 \
	    --pid-file ${workDir}ss.pid --log-file ${workDir}ss.log"

    echo $qrimg > $curConf			    #line1
    echo $method $pwd $ip $port >> $curConf	    #line2
    echo $cmd >> $curConf			    #3
    echo `date +%_H` >> $curConf			    #4

    $cmd
}

function checkOk(){
    `timeout 15 curl --insecure --silent --proxy socks5h://127.0.0.1:1080 https://twitter.com > /dev/null`
    ret=$?
    [ $ret -eq 0 ] && echo "ok" || echo "ng"
}


function getCurServer(){
    [ -f $curConf ] && echo "$(cat $curConf | head -n 1)"
}

function checkTime(){
    local curSlice=`date +%_H`
    let curSlice="$curSlice"/6

    local lastSlice
    if [ -f $curConf ];then
	lastSlice=`cat $curConf | awk 'NR==4 {print $0}'`
    fi
    [ $lastSlice ] || lastSlice=0
    let lastSlice="$lastSlice"/6
    [ $lastSlice == $curSlice ] || echo "do"
}

function update(){
    curSServer=$(getCurServer)
    for co in sg us jp;do
	for index in {a..c};do
	    tmpFile="${co}${index}.png"
	    if [ $specifyServer];then
		tmpFile=${specifyServer%.*}.png
		[ "$curSServer" == "$tmpFile" ] && pr_err "same as cur config"
	    fi

	    echo "current $tmpFile"
	    starfromQR $tmpFile
	    [ $(checkOk) == "ok" ] && break 2 || echo "---proxy $tmpFile ng,next---"
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
    curConf="${workDir}curConf.txt"
    while [ $# -gt 0 ];do
	case "$1" in
	    --server)
		specifyServer=$2
		shift
		;;
	    --checkTime)
		doSliceCheck=true
		;;
	esac
	shift
    done
}


    
function main(){
    argParser $@
    if [ $doSliceCheck ];then
	local doUpdate=$(checkTime)
	[ "$doUpdate" == "do" ] && update || echo "same time slice,exit"
    else
	update
    fi
}

main $@
