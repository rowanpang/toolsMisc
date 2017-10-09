#!/usr/bin/bash
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
pac="/var/www/html/rowan.pac"
port=1083
cmd="node shadowsocks-heroku/local.js -s rss-heroku.herokuapp.com -l 1083 -m \
	aes-256-cfb -k rss-heroku-ssr  -b 0.0.0.0"

oProxy=$(sed -n 's/\s\+var autoproxy = \(.\+\);/\1/p' $pac)
nProxy="'SOCKS ${dip}:$port'"
sed -i "s#\(var autoproxy = \).*;#\1$nProxy;#" $pac

$cmd

sed -i "s#\(var autoproxy = \).*;#\1$oProxy;#" $pac
