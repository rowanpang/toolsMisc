#!/usr/bin/bash
files="phome.sh.enc lvzl.sh.enc"

for f in $files;do
    echo "---cur:$f----"
    new=${f%.enc}
    if ! [ -f "./$new" ];then
	echo "---decrypt $f----"
	openssl enc -in $f -d -aec-256-cfb -out ${new}
    fi
done
