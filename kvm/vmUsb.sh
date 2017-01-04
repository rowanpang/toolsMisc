#!/bin/sh

function Usage(){
    echo "need param"
    echo "Usage: $program"
    echo "Usage: $program detach"
}

function verbose(){
    if [ "$DEBUG" == 'yes' ];then 
        echo $@
    fi
}

function lsuccess(){
    #green
    echo -e "\033[1;32m" "$@" "\033[0m"
}

function lwarn(){
    #33m,yellow
    echo -e "\033[1;33m" "$@" "\033[0m"
}

function lerror(){
    #31m,red
    echo -e "\033[1;31m" "$@" "exit -1""\033[0m"
    exit -1
}

function lsudo(){
    #green
    echo -e "\033[1;32msudo for:"\""$@"\""\033[0m"
    sudo "$@"
}

function callFunc(){
    verbose "=================func:$1 in========================"
    $1
    local ret=$?
    verbose "=================func:$1 finished=================="
    return $ret
}


function isDigital(){
    [ -n "$(echo $1 | sed -n "/^[0-9]\+$/p")" ] && echo "true"
    return 0
}

function listSelect(){
    local name=$1[@]
    local arrary=("${!name}")
    local min=0
    local let max=$((${#arrary[@]}-1))
    local sel=-1
    
    for i in "${!arrary[@]}";do
	echo "memer [$i]: ${arrary[$i]}"
    done
    #for item in "${arrary[@]}";do
        #echo "member: $item"
    #done

    if [ $max -lt 0 ];then
        verbose "none member,return -1"
        return -1
    elif [ $max -eq 0 ];then
        sel=0
        verbose "members just one"
    fi

    while [ -z "$sel" ]  || ! [ $(isDigital $sel) ] || \
          [ "$sel" -gt $max ] || [ "$sel" -lt $min ]; do

        echo -n "chose [${min}-$max]: "
        read sel
    done
    verbose "select:${arrary[$sel]}"

    return $sel
}

function domainSelec(){
    #local virshLines=$(virsh -c qemu:///system list --all | sed -n '3,$ p')
    local virshLines=$(virsh -c qemu:///system list --all | grep 'running')
    local oldIFS="$IFS"
    IFS=$'\n'
    local domains=( )
    local index=0
    for line in $virshLines;do
        [ -z $line ] && continue
        domain=$(echo $line | awk '{print $2}')
        domains[$index]=$domain
        let index+=1
    done
    IFS="$oldIFS"

    listSelect domains
    index=$?
    if [ $index -eq 255 ];then
        lerror "no domain found"    
    fi
    selectedDomain=${domains[$index]}
    verbose $selectedDomain
}

usbReg=${workDir}usbDev-*.xml
function usbSelecByFiles(){
    local usbs=( )
    local index=0
    for f in ${usbReg};do
        [ -f $f ] || continue
        verbose "found $f"
        usbs[$index]=`basename $f`
        let index+=1
    done

    verbose "found arrary ${usbs[@]}"

    listSelect usbs
    index=$?
    if [ $index -eq 255 ];then
        lerror "no usb device found"    
    fi
    selectedUsb=${usbs[$index]}
    verbose $selectedUsb
}

function usbSelecByDominAttached(){
    local domain=$1
    usbDevices=$(virsh -c qemu:///system dumpxml $domain | grep -A 3 "<hostdev mode='subsystem' type='usb'")
    echo $usbDevices
    vendors=($(echo $usbDevices | grep -oP "(?<=vendor id=')[^']+"))
    products=($(echo $usbDevices | grep -oP "(?<=product id=')[^']+"))
    
    echo ${vendors[@]}
    echo ${products[@]}

    local vIndex=0
    local matcheds=( )
    local mIndex=0
    for vid in "${vendors[@]}";do
        pid=${products[$vIndex]}
        verbose "vid:$vid,pid:$pid"
        for f in ${usbReg};do
            [ -f $f ] || continue
            verbose "try match $f"
            if [ $(cat $f | grep -o "$vid") ] && [ $(cat $f | grep -o "$pid") ];then
                verbose "$f matched for $vid:$pid"
                matcheds[$mIndex]=$(basename $f)
                let mIndex+=1
            fi
        done
        let vIndex+=1
    done
    echo ${matcheds[@]}

    listSelect matcheds 
    index=$?
    if [ $index -eq 255 ];then
        lerror "no usb device found"    
    fi
    selectedUsb=${matcheds[$index]}
    verbose $selectedUsb
}

function attach(){
    usbSelecByFiles
    local ret=$(virsh -c qemu:///system attach-device $selectedDomain ${workDir}${selectedUsb} 2>&1)
    if [ "$(echo $ret | grep 'error')" ];then
        lerror $ret
    else
        lsuccess $ret
    fi
}

function detach(){
    usbSelecByDominAttached $selectedDomain
    local ret=$(virsh -c qemu:///system detach-device $selectedDomain $selectedUsb 2>&1)
    if [ "$(echo $ret | grep 'error')" ];then
        lerror $ret
    else
        lsuccess $ret
    fi
}

#main
#default is attach usb dev to domain,if has arg will do detach
program=$0
DEBUG="yes"
workDir="$PWD/"
TAB="-e \t"
domainSelec
if [ $1 ];then
    detach
else
    attach
fi
