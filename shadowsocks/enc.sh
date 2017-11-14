#!/usr/bin/bash
files="phome.sh lvzl.sh rss-heroku.sh"

for f in $files;do
    echo "---cur:$f----"
    dec="./$f"
    enc="./enc-${f}"
    if ! [ -f "$dec" ] && [ -f $enc ];then
	echo "---decrypt $enc----"
	openssl enc -d -in $enc -aes-256-cfb -out ${dec}
    elif ! [ -f "$enc" ] && [ -f $dec ];then
	echo "---encrypt $dec----"
	openssl enc -in $dec -aes-256-cfb -out ${enc}
    fi
done
