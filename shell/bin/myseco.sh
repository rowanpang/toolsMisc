#/bin/bash

cd /usr/local/SecoClient

#depends on 'sh /etc/init.d/SecoClientPromoteService.sh start'
seccmd=./SecoClient
seclink=ipsec_vnic

tgts="10.152.30.10,80-82 10.152.20.11 10.152.11.50,63"

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
    $seccmd >/dev/null 2>&1 &
fi

trynum=1
trynumTotal=10
while :; do
    [[ $trynum -gt $trynumTotal ]] && echo "get $seclink gw error!  exit -1 ;" && exit -1;
    echo "try get $seclink gw, tryTotal:$trynumTotal,now:$trynum"
    gw=`ip r  |grep "dev $seclink.*link src" | awk '{print $NF}'`
    if [ "X$gw" != "X" ] ;then
        echo "get $seclink gw successful: $gw"
        break;
    fi

    sleep 1
    ((trynum++))
done

if [ `ip route |grep -c "default.*$seclink" ` -ge 1 ];then
    echo "delete default route via $gw $seclink"
    ip route delete to default dev $seclink
fi

#befRT current rt for tgt
befRT=(`ip r |grep "via $gw dev $seclink" | awk '{print $1}'`)
#echo "current rt via $gw dev $seclink: ${befRT[@]}"

nowRT=(${befRT[@]})

for tgt in $tgts ;do
    echo
    echo "try add sec route $tgt/32 via $gw"
    prefix=${tgt%.*}
    sfxs=${tgt##*.}
    i=0
    tarry=()

    for sfx in ${sfxs//,/ };do                      #10.152.30.80,82-85,89
        if ! [[ ${sfx/-/} == ${sfx} ]];then         #处理82-85
            beg=${sfx%-*}
            end=${sfx#*-}
            for s in `seq $beg $end`;do
                tarry[$i]=$prefix.$s
                ((i++))
            done
        else
            tarry[$i]=$prefix.$sfx                  #添加80/89
            ((i++))
        fi
    done

    #echo "target ips: ${tarry[@]}"                 #for dbg
    for tgtip in ${tarry[@]};do
        if [[ "X${nowRT[0]}" != "X" ]] && [[ ${nowRT[@]/${tgtip}/} != ${nowRT[@]} ]];then
            echo "route for $tgtip is exist, ip r to check"
            befRT=(${befRT[@]/${tgtip}/})
            continue
        fi
        echo "add route for $tgtip/32"
        ip route add to $tgtip/32 via $gw dev $seclink
        nowRT[${#nowRT[@]}]=$tgtip
    done
done
echo

#delete unused rt
for tgtdel in ${befRT[@]};do
    echo "delete rt for $tgtdel/32 via $gw dev $seclink"
    ip route del to $tgtdel/32 via $gw dev $seclink

    nowRT=( ${nowRT[@]/${tgtdel}/} )
done

#echo ${nowRT[@]}
#echo
#ip r
cd - > /dev/null 2>&1
