#!/bin/bash
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

port='1092'

pac="/var/www/html/rowan.pac"
oProxy=$(sed -n 's/\s\+var autoproxy = \(.\+\);/\1/p' $pac)
nProxy="'SOCKS ${dip}:${port}'"

sed -i "s#\(var autoproxy = \).*;#\1$nProxy;#" $pac

ss-redir -v -s 138.128.192.146 -p 443  -k N2I5NDBmN2 -m aes-256-cfb -b 0.0.0.0 -l $port

sed -i "s#\(var autoproxy = \).*;#\1$oProxy;#" $pac
