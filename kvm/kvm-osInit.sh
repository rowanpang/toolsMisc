#!/bin/bash
source ./osInitframe/lib.sh

function inspurInnerSecurity(){
    local bridgeName="iInner"
    local bridgeConName=$bridgeName
    if ! [ $(brctl show | grep -c $bridgeName) -gt 0 ];then
        pr_info "add bridge con $bridgeConName"
        nmcli connection add ifname $bridgeName con-name $bridgeConName type bridge
        nmcli connection up $bridgeConName
    fi
}

function kvmlocalBridge(){
    local bridgeName="bridge0"
    local bridgeConName=$bridgeName
    local slave=$(echo $(ip link | grep '^[1-9]\+: en*' | awk 'BEGIN {FS=":"} { print $2}') | awk '{print $1}')
    local slaveConName="${bridgeName}-slave-${slave}"

    local qemuConfig="/etc/qemu/bridge.conf"
    if [ $(cat $qemuConfig | grep -c $bridgeName) -lt 1 ];then
	lsudo sed -i "$ iallow bridge0" $qemuConfig
    fi

    if ! [ $(brctl show | grep -c $bridgeName) -gt 0 ];then
        pr_info "add bridge con $bridgeConName"
        nmcli connection add ifname $bridgeName con-name $bridgeConName type bridge
        nmcli connection up $bridgeConName
    fi
    if ! [ $(brctl show | grep $bridgeName | grep -c $slave) -gt 0 ];then
        pr_info "add slave $slave to $bridgeName and make connection $slaveConName"
        nmcli connection add ifname ${slave} con-name $slaveConName type  bridge-slave master $bridgeName
        nmcli connection up $slaveConName
    fi

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

    kvmlocalBridge
    inspurInnerSecurity
}

baseInit
