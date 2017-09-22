#!/bin/bash
source ./osInitframe/lib.sh

function addBridgeAndSlave(){
    local bridgeName=$1
    local slave=$2
    local i3StatCfg="$HOME/.config/i3status/config"	    #remenber modify

    local bridgeConName=$bridgeName
    if ! [ $(brctl show | grep -c $bridgeName) -gt 0 ];then
        pr_info "add bridge con $bridgeConName"
        nmcli connection add ifname $bridgeName con-name $bridgeConName type bridge
	nmcli connection modify br-sec connection.autoconnect-slaves 1
        nmcli connection up $bridgeConName
    fi

    if [ "$slave" ];then
	local slaveConName="brSlave-${bridgeName#br-}-${slave}"
	if ! [ $(brctl show | grep $bridgeName | grep -c $slave) -gt 0 ];then
	    pr_info "add slave $slave to $bridgeName and make connection $slaveConName"
	    nmcli connection add ifname ${slave} con-name $slaveConName type  \
				    bridge-slave master $bridgeName
	    nmcli connection up $slaveConName
	fi
    fi
}

function br-sec(){
    local bridgeName="br-sec"
    local slave="enp2s0"
    addBridgeAndSlave $bridgeName $slave
}

function br-wan(){
    local bridgeName="br-wan"
    local slave="ethUsbr30f8"

    local qemuConfig="/etc/qemu/bridge.conf"
    if [ $(cat $qemuConfig | grep -c $bridgeName) -lt 1 ];then
	lsudo sed -i "$ iallow $bridgeName" $qemuConfig
    fi

    addBridgeAndSlave $bridgeName $slave
}

function br-kvmlan(){
    local dir=$localdir
    local cmd=${dir}vmNet.sh
    local lan='virtNet-Isolated'
    local lancfg=${dir}${lan}.xml
    sed -in "s/\(<hostname>\)rowanInspur/\1${HOSTNAME%.*}/p" $lancfg

    $cmd -n $lan
    virsh -c qemu:///system net-autostart $lan
}

function usbNetUdev(){
    local dir=$localdir
    local uRulesDir="/etc/udev/rules.d/"
    local rfile="99-usbNetUdev.rules"
    lsudo cp ${dir}${rfile} ${uRulesDir}
}

function baseInit(){
    local dir=$localdir
    pkgCheckInstall virt-manager
    pkgCheckInstall libvirt-client
    pkgCheckInstall tigervnc
    [ $? -eq 0 ] && lsudo usermod --append --groups kvm,qemu,libvirt $USER

    local kvmDir=${HOMEDIR}vm-iso/
    [ -d $kvmDir ] || mkdir -p $kvmDir
    ln -rsf ${dir}/fw24.xml ${dir}template.xml
    ln -sf ${dir}/vmStart.sh ${kvmDir}vmStart.sh
    ln -sf ${dir}/isoMK.sh ${kvmDir}isoMK.sh
    ln -sf ${dir}/vmUsb.sh ${kvmDir}vmUsb.sh
    ln -sf ${dir}/vmNet.sh ${kvmDir}vmNet.sh

    pkgCheckInstall bridge-utils
    pkgCheckInstall NetworkManager

    br-wan
    br-sec
    br-kvmlan
    usbNetUdev
}

baseInit
