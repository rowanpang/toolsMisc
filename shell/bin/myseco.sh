#/bin/bash

cd /usr/local/SecoClient

#depends on 'sh /etc/init.d/SecoClientPromoteService.sh start'
seccmd=./SecoClient
seclink=ipsec_vnic
tgts="10.152.30.10 10.152.20.11 10.152.11.63 10.152.11.50"
tgts="10.152.30.10 10.152.20.11 10.152.11.63"

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
    gw=`ip r  |grep "dev $seclink.*link src" | awk '{print $NF}'`
    if [ "X$gw" != "X" ];then
        echo "get $seclink gw successful: $gw"
        break;
    fi
    sleep 1
done

#curRT current rt for tgt
curRT=(`ip r |grep "via $gw dev $seclink" | awk '{print $1}'`)
echo "current rt via $gw dev $seclink: ${curRT[@]}"

if [ `ip route |grep -c "default.*$seclink" ` -ge 1 ];then
    echo "delete default route via $gw $seclink"
    ip route delete to default dev $seclink
fi

for tgt in $tgts ;do
    echo "try add sec route $tgt/32 via $gw"

    if [[ ${curRT[@]/${tgt}/} != ${curRT[@]} ]];then
        echo "route for $tgt is exist, ip r to check"
        curRT=(${curRT[@]/${tgt}/})
        continue
    fi
    ip route add to $tgt/32 via $gw dev $seclink
done

#delete unused rt
rtTorm=${#curRT[@]}
if [[ $rtTorm -ge 1 ]] && [[ "${curRT[0]}" != "default" ]];then
    echo "need to delete rt for ${curRT[@]}"
    for (( i=0; i < $rtTorm; i++));do
        echo "delete rt for ${curRT[i]}/32 via $gw dev $seclink"
        ip route del to ${curRT[i]}/32 via $gw dev $seclink
    done
fi

cd -
