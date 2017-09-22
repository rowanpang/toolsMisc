#!/bin/sh

function Usage(){
    echo "Usage: $program   for start"
    echo "Usage: $program   -s/-ls/-l/-d/-ld/-u   start,list,destroy,undefine"
    echo "Usage: $program   -n  specify the netXml to define"
    echo "Usage: $program   -h  for this help"
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
    if [ $? -eq 1 ];then
        echo -e "\033[1;32m""sudo authen error exit -1""\033[0m"
        exit -1
    fi
}

function callFunc(){
    local func=$1
    shift
    verbose "=================func:$func in========================"
    $func "$@"
    local ret=$?
    verbose "=================func:$func finished=================="
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
    #for item in "${arrary[@]}";do	    #equal with upon
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

	echo -n "chose [${min}-$max]($min): "
        read sel
	[ -z "$sel" ] && sel=$min	#just enter use default
    done
    verbose "select:${arrary[$sel]}"

    return $sel
}

function argParser(){
    program=$0
    selVirtNetXml=""

    DEBUG="no"
    workDir="$PWD/"
    if [ -L $program ];then
	xmlCfgDir="$(dirname $(readlink -n $program))/"
    else
	xmlCfgDir="$(dirname $program)/"
    fi

    doCmds="list start list"
    while [ $# -gt 0 ];do
	case "$1" in
	    -l)
		doCmds="list"
		;;
	    -s)
		doCmds="start"
		;;
	    -ls)
		doCmds="list start"
		;;
	    -d)
		doCmds="destroy"
		;;
	    -u)
		doCmds="undefine"
		;;
	    -h)
		Usage
		exit 0
		;;
	    -n)
		specifyNet=$2
		shift
		;;
	esac
	shift
    done
}

function dolist(){
    virsh -c qemu:///system net-list --all | grep --color -E '^|active'
}

function vNetStartSel(){
    local domains=( )
    local index=0
    local virNets="${xmlCfgDir}virtNet-*"

    for line in $virNets ;do
        [ -z $line ] && continue
        domain=$line
        domains[$index]=$domain
        let index+=1
    done

    listSelect domains
    index=$?
    if [ $index -eq 255 ];then
        lerror "no virtNet found"
    fi
    selVirtNetXml=${domains[$index]}
    verbose $selVirtNetXml
}

function doStart(){
    if [ "$specifyNet" ];then
	selVirtNetXml=${xmlCfgDir}${specifyNet%.xml}.xml
    else
	vNetStartSel
    fi

    selVirtNetName=$(basename $selVirtNetXml)
    selVirtNetName=${selVirtNetName%.*}

    virsh -c qemu:///system net-define $selVirtNetXml
    virsh -c qemu:///system net-start $selVirtNetName
}

function vNetDestroySel(){
    local virshLines=$(virsh -c qemu:///system net-list --all | grep '\sactive')
    local oldIFS="$IFS"
    IFS=$'\n'

    local domains=( )
    local index=0
    for line in $virshLines;do
        [ -z $line ] && continue
        domain=$(echo $line | awk '{print $1}')
        domains[$index]=$domain
        let index+=1
    done
    IFS="$oldIFS"

    if [ $index -eq 0 ];then
        lerror "no active virtNet found"
    fi

    listSelect domains
    index=$?
    if [ $index -eq 255 ];then
        lerror "no virtNet found"
    fi
    selVirtToDestroy=${domains[$index]}
    verbose $selVirtToDestroy
}

function doDestroy(){
    vNetDestroySel
    virsh -c qemu:///system net-destroy $selVirtToDestroy
}

function vNetUndefineSel(){
    local virshLines=$(virsh -c qemu:///system net-list --all | grep 'active')
    local oldIFS="$IFS"
    IFS=$'\n'

    local domains=( )
    local index=0
    for line in $virshLines;do
        [ -z $line ] && continue
        domain=$(echo $line | awk '{print $1}')
        domains[$index]=$domain
        let index+=1
    done
    IFS="$oldIFS"

    if [ $index -eq 0 ];then
        lerror "no defined virtNet found"
    fi

    listSelect domains
    index=$?
    if [ $index -eq 255 ];then
        lerror "no virtNet found"
    fi
    selVirtToUndefine=${domains[$index]}
    verbose $selVirtToUndefine
}

function doUndefine(){
    vNetUndefineSel
    virsh -c qemu:///system net-undefine $selVirtToUndefine
}

#main
argParser $@

for perCmd in $doCmds;do
    lsuccess "-------do $perCmd--------"
    case "$perCmd" in
	"list")
	    dolist
	    ;;
	"start")
	    doStart
	    ;;
	"destroy")
	    doDestroy
	    ;;
	"undefine")
	    doUndefine
	    ;;
    esac
done
