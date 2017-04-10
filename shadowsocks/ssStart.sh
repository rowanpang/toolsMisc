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
    qrimg=$1
    quiet="-q"
    wget $quiet -O ${workDir}$qrimg http://xyz.ishadow.online/img/qr/${qrimg}
    info=$(zbarimg $quiet ${workDir}$qrimg)
    base64=${info#QR-Code:ss://}
    confs=$(echo $base64 | base64 -d)
    oifs=$IFS
    IFS=':'
    parserConfs $confs
    IFS="$oifs"
    bindip="localhost"
    [ `expr match "$(hostname)" 'rowanInspur'` ] && bindip="0.0.0.0"

    echo $qrimg > $curConf
    echo $method $pwd $ip $port >> $curConf
    cmd="sslocal $quiet -d restart -s $ip -p $port -k $pwd -m $method    \
	    -b $bindip -l 1080						 \
	    --pid-file ${workDir}ss.pid --log-file ${workDir}ss.log"

    echo $cmd >> $curConf
    $cmd
}

function checkOk(){
    `timeout 15 curl --insecure --silent --proxy socks5h://127.0.0.1:1080 https://twitter.com > /dev/null`
    ret=$?
    [ $ret -eq 0 ] && echo "ok" || echo "ng"
}


function getcurConf(){
    [ -f $curConf ] && echo "$(cat $curConf | head -n 1)"
}

function gotworkDir(){
    local prog=$1
    local wDir
    [ -L $prog ] && wDir=$(dirname `readlink $prog`)
    wDir=$(dirname $prog)

    echo "${wDir}/"
}

workDir=$(gotworkDir $0)
curConf="${workDir}curConf.txt"
curSServer=$(getcurConf)
specify=$1

for co in sg us jp;do
    for index in {a..c};do
	tmpFile="${co}${index}.png"
	if [ $specify ];then
	    tmpFile=${specify%.*}.png
	    [ "$curSServer" == "$tmpFile" ] && pr_err "same as cur config"
	fi

	echo "current $tmpFile"
	starfromQR $tmpFile
	[ $(checkOk) == "ok" ] && break 2 || echo "---proxy $tmpFile ng,next---"
    done
done
