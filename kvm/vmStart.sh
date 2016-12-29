#!/bin/sh
#howToUse:
	#1,configIterm need Modify
		#xmlTemplate
		#domainSavedDir
		#imgSizeWhenAutoCreate='25G'
	#2,./vmStart.sh *.xml or *.iso

#howTodebug
	

#depend on
	#1,qemu-img to gen imgDisk
	#2,awk/sed/python
	#3,netstat auto find vncport
	#4,i3-msg adjust win
	#5,uuidgen,auto gen uuid

program=$0
DEBUG="yes"

function Usage(){
	echo "need param"
	echo "Usage: $program 'domain'"
}
function verbose(){
	[ $DEBUG == "yes" ] && {  $@; }
}
TAB="-e \t"
#check param
if [ $# -lt 1 ];then
	Usage
	exit -1;
fi	

domain=${1%.*}
workdir="$PWD/"
xmlConfig=${domain}.xml
xmlTemplate="$(dirname $(readlink -n $program))/template.xml"

imgSizeWhenAutoCreate='25G'
imgDisk=${workdir}${domain}.img
logFile="${workdir}serial-${domain}.log"
domainIso=${workdir}${domain}.iso

uri="system"
if [ "$uri" == "system" ];then
	#TODO
	domainSavedDir="/home/$USER/.config/libvirt/qemu/save/"
	domainSaved=$domainSavedDir$domain.save

	lvirsh="sudo virsh"
	lnetstat="sudo netstat"
	lchmod="sudo chmod"
else
	domainSavedDir="/home/$USER/.config/libvirt/qemu/save/"
	domainSaved=$domainSavedDir$domain.save

	lvirsh="virsh"
	lnetstat="netstat"
	lchmod="chmod"
fi

function domainCreate(){
	local ret;
	if [ -r $domainSaved ];then
		verbose echo "restore domain $domainSaved"
		$lvirsh restore $domainSaved
		ret=$?
		rm -rf $domainSaved
	else
		verbose echo "define&start domain from $xmlConfig"
		$lvirsh define $xmlConfig
		$lvirsh start ${domain}
		ret=$?
	fi

	if [ $ret -eq 0 ];then
		echo -e "\033[1;32mdomain $xmlConfig up\033[0m"
	else
		echo -e "\033[1;31mdomain $xmlConfig up failed,exit -1\033[0m"
		exit -1
	fi
}

#confirm vncPort for domain throw /proc/$pid/cmdline
function gotDomainVncPort(){
	local pid port pids
	local pidPorts=( )
	oldIFS="$IFS"
	#allVnc=`sudo netstat -nptl 2>/dev/null | grep ":59[0-9][0-9]"`
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

function vncViewer(){
	$lchmod a+rw $logFile

	local vncPort=""
	vncPort=$(gotDomainVncPort)
	echo "vncPort: $vncPort"
	vncviewer :$vncPort   >/dev/null 2>&1

	$lvirsh destroy $domain
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

function checkXml(){
	[ -f $xmlConfig ] && return
	verbose echo -e "\033[1;33m\t\tauto gen $xmlConfig\033[0m"
	cp $xmlTemplate $xmlConfig
	local uuid=$(uuidgen) 
	verbose echo "$TAB random uuid\t:$uuid"
#kvm uuid
    sed -i "s#<uuid>\S\+</uuid>#<uuid>$uuid</uuid>#" $xmlConfig
	#sed -i "#<uuid>\S\+</uuid># d" $xmlConfig
#kvm name	
	sed -i "s#<name>\S\+</name>#<name>$domain</name>#" $xmlConfig
#kvm source file
	sed -i "s#\(\s\+<source file=\)\s*\S\+.img'/>#\1\'$imgDisk\'/>#" $xmlConfig 
	sed -i "s#\(\s\+<source file=\)\s*\S\+.iso'>#\1\'$domainIso\'>#" $xmlConfig
	sed -i "s#\(\s\+<source path=\)\s*\S\+.log'/>#\1\'$logFile\'/>#" $xmlConfig
#kvm vnc port autoport
	#skip
#kvm mac
	local macStr=$(echo `sed -n '/<mac address/p' $xmlConfig`)
	macStr=${macStr##\<mac address=\'}
	macStr=${macStr%%\'/>}
	local macHex="0x$(echo $macStr | sed -n 's/://gp')"
	verbose echo "$TAB oldmacHex\t:$macHex"
	local newMac=$(awk "BEGIN{num=strtonum($macHex);printf(\"%X\n\",num+$RANDOM)}")
	verbose echo "$TAB newMacHex\t:$newMac"
	newMacStr=$(echo $newMac | sed -r 's/^([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})/\1:\2:\3:\4:\5:\6/')
	verbose echo "$TAB newMacStr\t:$newMacStr"
	sed -i "s#\(\s\+<mac address=\)\s*\S\+'/>#\1\'$newMacStr\'/>#" $xmlConfig
}

function checkImg(){
	[ -f $imgDisk ] && return
	verbose echo -e "\033[1,33m\t\tauto create $imgDisk\033[0m" 
	qemu-img create $imgDisk $imgSizeWhenAutoCreate
}

function check(){
	checkImg && checkXml
}

#main

check || exit

curWS=$(getCurWorkSpace)
echo "domain: $domain"
echo "xmlConfig: $xmlConfig"
echo "curWorkSpace: $curWS"
#topleft 10 20
#top right 1330 10
domainCreate
i3-msg 'floating toggle ;resize set 270 200;move position 1330 00' >/dev/null 2>&1
vncViewer

timeWait=0
sliceWait=1
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
