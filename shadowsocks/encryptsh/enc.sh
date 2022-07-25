#!/usr/bin/bash
files="lgm.sh phome.sh lvzl.sh rss-heroku.sh lvzl-redir.sh predir.sh"

#read -s -p "Password: " pwd
#echo
#read -s -p "Password Confirm: " pwd1
#echo

if ! [ "$pwd" == "$pwd1" ];then
    echo "--pwd not equal-- exit"
    exit
fi

kfile="/root/Nutstore/OS/Linux/network/osi/7-application/ssh/rowanKey/rowanpang/id_rsa"
pwd=`sed -n '3p' $kfile`

for f in $files;do
    echo "---cur:$f----"
    dec="./$f"
    enc="./enc-${f}"
    if ! [ -f "$dec" ] && [ -f $enc ];then
	echo "-----decrypt $enc----"
	openssl enc -d -in $enc -aes-256-cfb -out ${dec} -pass pass:$pwd
	chmod +x $dec
	#openssl enc -d -in $enc -aes-256-cfb -out ${dec} -kfile $kfile
    elif ! [ -f "$enc" ] && [ -f $dec ];then
	echo "-----encrypt $dec----"
	openssl enc -in $dec -aes-256-cfb -out ${enc} -pass pass:$pwd
	#openssl enc -in $dec -aes-256-cfb -out ${enc} -kfile $kfile
    fi
done
