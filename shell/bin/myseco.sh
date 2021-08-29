#/bin/bash

cd /usr/local/SecoClient

#depends on 'sh /etc/init.d/SecoClientPromoteService.sh start'
seccmd=./SecoClient
seclink=ipsec_vnic
ips="10.152.30.10 10.152.20.11"

spid=`pgrep SecoClientPromo`
if [ "X$spid" != "X" ];then
    echo "SecoClientPromoteService running... $spid"
else
    sh /etc/init.d/SecoClientPromoteService.sh start
fi

pid=`pgrep '^SecoClient$'`
if [ "X$pid" != "X" ];then
    echo "$seccmd running, pid $pid"
else
    $seccmd &
    sleep 5
fi

while :; do
    echo "try get $seclink gw"
    gw=`ip r  |grep $seclink | awk '{ if(NR==2) print $NF}'`
    if [ "X$gw" != "X" ];then
        echo "get $seclink successful: $gw"
        break;
    fi
    sleep 1
done

if [ `ip route |grep -c "default.*$seclink" ` -ge 1 ];then
    echo "delete default route via $gw $seclink"
    ip route delete to default dev $seclink
fi

for ip in $ips ;do
    echo "try add sec route $ip/32 via $gw"
    if [ `ip route |grep -c "$ip.*$seclink" ` -ge 1 ];then
        echo "route for $ip is exist, ip r to check"
        continue
    fi
    ip route add to $ip/32 via $gw dev $seclink
done

cd -
