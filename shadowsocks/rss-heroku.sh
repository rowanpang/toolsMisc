#!/usr/bin/bash
function gotworkDir(){
    local prog=$1
    local wDir
    [ -L $prog ] && wDir=$(dirname `readlink $prog`) || wDir=$(dirname $prog)
    basepath=$(cd $wDir; pwd)
    echo "$basepath/"
}

function run(){
    olddir="$PWD"
    runDir=$(gotworkDir $0)
    workDir="${runDir}shadowsocks-heroku"
    cd $workDir

    hostPrefix="rss-heroku"
    key="rss-heroku-ssr"
    hostPrefix="rss-heroku-gmail"
    key="xiaoYan*#0515"
    host="$hostPrefix.herokuapp.com"

    #cnt:key:port
    cntKeys="rss-heroku:rss-heroku-ssr:1083 rss-heroku-gmail:xiaoYan*#0515:1084"

    dlink=$(ip route | grep default |		    \
	    awk '{
		    i=1;
		    while(i<NF){
			if($i=="dev"){
			    print $(i+1)
			};
			i++
		    }
		}')
    dip=$(ip a s $dlink | grep 'inet ' | awk '{print $2}' | \
	    awk 'BEGIN{ FS="/" };
		{
		    print $1
		}')

    iter=`which node`
    for cntKey in $cntKeys;do
	cnt=`echo "$cntKey" | awk 'BEGIN { FS=":" } { print $1 }'`
	key=`echo "$cntKey" | awk 'BEGIN { FS=":" } { print $2 }'`
	port=`echo "$cntKey" | awk 'BEGIN { FS=":" } { print $3 }'`

	host="${cnt}.herokuapp.com"
	cmd="daemonize -v -c $workDir $iter local.js -s $host
		-l $port -m aes-256-cfb -k $key -b 0.0.0.0"
	$cmd
    done

    pac="/var/www/html/rowan.pac"
    pacPort=1084

    oProxy=$(sed -n 's/\s\+var autoproxy = \(.\+\);/\1/p' $pac)
    nProxy="'SOCKS ${dip}:$pacPort'"

    sed -i "s#\(var autoproxy = \).*;#\1$nProxy;#" $pac
    #sed -i "s#\(var autoproxy = \).*;#\1$oProxy;#" $pac
    cd $olddir
}

run
