#!/bin/sh
#howToUse:
    #1,configIterm need Modify
        #xmlTemplate
        #domainSavedDir
        #imgSizeWhenAutoCreate='25G'
    #2,./vmStart.sh *.xml or *.iso

#depend on
    #1,qemu-img to gen imgDisk
    #2,awk/sed/python
    #3,netstat auto find vncport
    #4,i3-msg adjust win
    #5,uuidgen,auto gen uuid

function Usage(){
    echo -e "Usage: $program [opt] 'domain'"
    echo -e "\t\t -l,list: list vm status"
    echo -e "\t\t -q,quit: quit shell"
    echo -e "\t\t -s,size: imge disk size,default 25G"
    echo -e "\t\t -n,noVnc: not startup vncViewer"
    echo -e "\t\t -t,shut: shutdown vm"
    echo -e "\t\t -d,destroy: destroy vm"
}

function lsudo(){
    #green
    echo -e "\033[1;32msudo for:"\""$@"\""\033[0m"
    sudo "$@"
}

function verbose(){
    [ $DEBUG == "yes" ] && {  $@; }
}

#confirm vncPort for domain throw /proc/$pid/cmdline
function gotDomainVncPort(){
    local pid port pids
    local pidPorts=( )
    oldIFS="$IFS"
    #allVnc=`lsudo netstat -nptl 2>/dev/null | grep ":59[0-9][0-9]"`
    tmp=`$lnetstat -nptl 2>/dev/null`

    IFS=$'\n'
    allVnc=`echo "$tmp" | grep ":59[0-9][0-9]"`
    for vnc in $allVnc;do
        unset pid port
        pid=$(echo $vnc | awk '{print $7}' | sed 's#\([0-9]\+\)/.*#\1#')
        port=$(echo $vnc | awk '{print $4}' | sed 's/.*:\(59[0-9][0-9]\)/\1/')
        pids="$pid $pids"
        pidPorts[$pid]=$port
    done
    IFS="$oldIFS"

    #trim ^\s and \s$
    pids=$(echo $pids | sed 's/^\s\?\([0-9]\+\)\s\?$/\1/')
    for pid in $pids;do
        count=$(cat /proc/$pid/cmdline | grep "domain-[0-9]\+-${domain:0:20}" -c)
        if [ $count -gt 0 ];then
            echo ${pidPorts[$pid]}
            match="yes"
            break;
        fi
    done
    [ $match ] || { echo -e "\033[1;31m\t\terror!!!not found vnc port for $domain,exit -2\033[0m" && exit -2; }
}

function doVncViewer(){
    if [ "$noVncViewer" == 'true' ];then
	return
    fi
    $lchmod a+rw $logFile
    local vncPort=""
    vncPort=$(gotDomainVncPort)
    echo "vncPort: $vncPort"
    if [ "$quitShell" ];then
	vncviewer :$vncPort   >/dev/null 2>&1 &
	exit
    else
	xwidth=$(xrandr --current | grep --only-matching 'current\s\+[0-9]\+ x [0-9]\+' | awk '{print $2}')
	xhigh=$(xrandr --current | grep --only-matching 'current\s\+[0-9]\+ x [0-9]\+' | awk '{print $4}')
	xSize=200
	ySize=600
	let px=${xwidth}-${xSize}-10
	let py=10

	#top-left 10 20
	#top-right 1330 10
	i3-msg "floating toggle ;resize set $xSize $ySize;move position $px $py" >/dev/null 2>&1
	vncviewer :$vncPort   >/dev/null 2>&1

	local timeWait=0
	local sliceWait=1
	while [ 0 ];do
	    hereWS=$(getCurWorkSpace)
	    if [ $hereWS -eq $curWS ];then
		break
	    else
		sleep $sliceWait
		let timeWait+=$sliceWait
		echo "had wait for focus: $timeWait seconds"
	    fi
	done
	i3-msg 'floating toggle'  >/dev/null 2>&1

	echo
	read -p "Any input will not destroy $domain: " select
	if ! [ "$select" ];then
	    $lvirsh destroy $domain
	fi
    fi
}

function getCurWorkSpace(){
    pyName=/tmp/getFocusWorkSpace.py
cat << EOF > $pyName
#!/bin/env python

import sys
import os
import json

jsonStr=os.popen('i3-msg -t get_workspaces').readline()
dicts = json.loads(jsonStr)
for d in dicts:
    if d['focused'] == True:
        print d['num']
EOF

    chmod a+x $pyName
    curWorkSpace=$($pyName)
    echo $curWorkSpace
    rm $pyName
}

function gotNewMac(){	    #$1=52:54:00:9c:7b:6e
    local macStr=`echo $1`
    local macHex="0x$(echo $macStr | sed -n 's/://gp')"
    verbose echo "$TAB oldmacHex\t:$macHex"
    local newMac=$(awk "BEGIN{num=strtonum($macHex);printf(\"%X\n\",num+$RANDOM)}")
    verbose echo "$TAB newMacHex\t:$newMac"
    newMacStr=$(echo $newMac | sed -r 's/^([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})/\1:\2:\3:\4:\5:\6/')
    verbose echo "$TAB newMacStr\t:$newMacStr"
}

function checkXml_newMAC(){
    local macStr=$(echo `sed -n '/<mac address/p' $xmlConfig`)
    local macs=$(sed -n '/<mac address/p' $xmlConfig | sed "s/<mac address='//g" | sed "s/'\/>//g")
    for mac in `echo $macs`;do
	gotNewMac $mac
	sed -i "s#\(\s\+<mac address=\)'$mac'/>#\1\'$newMacStr\'/>#" $xmlConfig
    done
    domainShort="${domain:0:10}"

    sed -i "s/\(<target dev='kwan-\)xxx/\1${domainShort}/p" $xmlConfig
    sed -i "s/\(<target dev='klan-\)xxx/\1${domainShort}/p" $xmlConfig
}

function checkXml_Source(){
    sed -i "s#\(\s\+<source file=\)\s*\S\+.img'/>#\1\'$imgDisk\'/>#" $xmlConfig
    sed -i "s#\(\s\+<source file=\)\s*\S\+.iso'>#\1\'$domainIso\'>#" $xmlConfig
    sed -i "s#\(\s\+<source path=\)\s*\S\+.log'/>#\1\'$logFile\'/>#" $xmlConfig
}

function checkXml_basic(){
#kvm uuid
    local uuid=$(uuidgen)
    verbose echo "$TAB random uuid\t:$uuid"
    sed -i "s#<uuid>\S\+</uuid>#<uuid>$uuid</uuid>#" $xmlConfig
#kvm name
    sed -i "s#<name>\S\+</name>#<name>$domain</name>#" $xmlConfig
}

function checkXml(){
    [ -f $xmlConfig ] && return
    verbose echo -e "\033[1;33m\t\tauto gen $xmlConfig\033[0m"
    cp $xmlTemplate $xmlConfig

    checkXml_basic
    checkXml_Source
    #kvm vnc port autoport #skip
    checkXml_newMAC
}

function checkImg(){
    [ -f $imgDisk ] && return
    verbose echo -e "\033[1;33m\t\tauto create $imgDisk\033[0m"
    qemu-img create $imgDisk $imgSizeWhenAutoCreate
}

function check(){
    checkImg && checkXml
}

function domainCreate(){
    local ret;

    if [ -r $domainSaved ];then
        verbose echo "restore domain $domainSaved"
        $lvirsh restore $domainSaved
        ret=$?
        rm -rf $domainSaved
    else
	check
        verbose echo "define&start domain from $xmlConfig"
        $lvirsh define $xmlConfig
        $lvirsh start ${domain}
        ret=$?
	$lvirsh undefine $domain
    fi

    if [ $ret -eq 0 ];then
        echo -e "\033[1;32mdomain $xmlConfig up\033[0m"
    else
        echo -e "\033[1;31mdomain $xmlConfig up failed,exit -1\033[0m"
        exit -1
    fi
}

function domainState(){
    echo "$($lvirsh domstate $domain 2>/dev/null)"
}

function optParser(){
    program=$0
    if [ $# -lt 1 ];then
        Usage
        exit -1;
    fi

    while [ $# -gt 0 ]; do
	case "$1" in
	    -l|list)
		doWhat="list"
		break
		;;
	    -t|shut)
		doWhat="shut"
		vmtoShut="${2}"
		shift
		break
		;;
	    -d|destroy)
		doWhat="destroy"
		vmtoDestroy="${2}"
		shift
		break
		;;
	    -q|quit)
		quitShell="true"
		;;
	    -s|size)
		imgSizeWhenAutoCreate="${2}"
		shift
		;;
	    -n|noVnc)
		noVncViewer="true"
		;;
	    -h|help)
		Usage
		exit -1;
		;;
	    *)
		domain=${1%.*}
		;;
	esac

	shift
    done

    DEBUG="yes"
    TAB="-e \t"

    workdir="$HOME/vm-iso/"
    logDir="${workdir}logFile/"
    [ -d $logDir ] || mkdir -p $logDir
    xmlConfig=${workdir}${domain}.xml

    #--------var used by xmlCheck,imgCheck

    if [ -L $program ];then
	xmlTemplate="$(dirname $(readlink -n $program))/template.xml"
    else
	xmlTemplate="$(dirname $program)/template.xml"
    fi

    [ "$imgSizeWhenAutoCreate" ] || imgSizeWhenAutoCreate='25G'
    imgDisk=${workdir}${domain}.img
    logFile="${logDir}serial-${domain}.log"
    domainIso=${workdir}${domain}.iso

    #-----------var end

    uri="system"
    if [ "$uri" == "system" ] && [ $EUID -ne 0 ];then
	#TODO
	domainSavedDir="$HOME/.config/libvirt/qemu/save/"
	domainSaved=$domainSavedDir$domain.save

	lvirsh="lsudo virsh"
	if [ "$(id | grep libvirt)" ];then
	    lvirsh="virsh -c qemu:///system"
	fi
	lnetstat="lsudo netstat"
	lchmod="lsudo chmod"
    else
	domainSavedDir="$HOME/.config/libvirt/qemu/save/"
	domainSaved=$domainSavedDir$domain.save

	lvirsh="virsh"
	lnetstat="netstat"
	lchmod="chmod"
    fi
    #echo $lvirsh
}


function dolist(){
    virsh list --all 2>&1
    virsh -c qemu:///system list --all 2>&1
}

function doshut(){
    virsh -c qemu:///system shutdown $1 2>&1
}

function main(){
    optParser "$@"

    case "$doWhat" in
	"list")
	    dolist
	    ;;
	"shut")
	    doshut $vmtoShut
	    shift
	    ;;
	"destroy")
	    virsh -c qemu:///system destroy $vmtoDestroy 2>&1
	    shift
	    ;;

	*)
	    doWhat="create"
	    ;;
    esac

    [ "$doWhat" == "create" ] || exit

    curWS=$(getCurWorkSpace)
    echo "domain: $domain"
    echo "xmlConfig: $xmlConfig"
    echo "curWorkSpace: $curWS"
    if [ "$(domainState)" != "running" ];then
	echo "not running create"
	domainCreate
    fi

    doVncViewer
}

#main
main "$@"
