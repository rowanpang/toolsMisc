#!/bin/bash

function disableSelinux(){
    if [ `selinuxenabled` ];then 
        lsudo setenforce 0
        lsudo sed -i 's;SELINUX=enforcing;SELINUX=disabled;' /etc/selinux/config
    fi
}

function initCheck(){
    local who=`whoami`
    [ "$who" == "$USER" ] || lerror "effective user:$who is not login user:$USER"
    [ -f ${HOMEDIR}.gitconfig ] || lerror " prepare .gitconfig first,exit" 
    [ -f ${HOMEDIR}.ssh/id_rsa ] || lerror "prepare ssh key first,exit"

    local preDir="$PWD"
}



#called by initToolsMisc,shouldn't directly call
function toolsMisc_kvm(){
    [ $1 ] || lerror "init kvm need dir param"
    local dir=$1
    pkgCheckInstall virt-manager
    [ $? ] && lsudo usermod --append --groups libvirt $USER
    pkgCheckInstall libvirt-client

    local kvmDir=${HOMEDIR}vm-iso/
    [ -d $kvmDir ] || mkdir -p $kvmDir
    ln -rsf ${dir}kvm/fw24.xml ${dir}kvm/template.xml
    ln -sf ${dir}kvm/vmStart.sh ${kvmDir}vmStart.sh
    ln -sf ${dir}kvm/isoMK.sh ${kvmDir}isoMK.sh
    ln -sf ${dir}kvm/vmUsb.sh ${kvmDir}vmUsb.sh

    pkgCheckInstall bridge-utils
    pkgCheckInstall NetworkManager

    local bridgeName="bridge0"
    local bridgeConName=$bridgeName
    local slave=$(ip link | grep '^[1-9]\+: en*' | awk 'BEGIN {FS=":"} { print $2}')
    local slaveConName="${bridgeName}-slave-${slave}"

    local qemuConfig="/etc/qemu/bridge.conf"
    if [ $(cat $qemuConfig | grep -c $bridgeName) -lt 1 ];then
	lsudo sed -i "$ iallow bridge0" $qemuConfig
    fi

    if ! [ $(brctl show | grep -c $bridgeName) -gt 0 ];then
        verbose "add bridge con $bridgeConName"
        nmcli connection add ifname $bridgeName con-name $bridgeConName type bridge
        nmcli connection up $bridgeConName
    fi
    if ! [ $(brctl show | grep $bridgeName | grep -c $slave) -gt 0 ];then
        verbose "add slave $slave to $bridgeName and make connection $slaveConName"
        nmcli connection add ifname ${slave} con-name $slaveConName type  bridge-slave master $bridgeName
        nmcli connection up $slaveConName
    fi
}

#called by initToolsMisc,shouldn't directly call
function toolsMisc_diskMount(){
    [ $1 ] || lerror "init diskMount need dir param"
    local dir=$1
    local uRulesDir="/etc/udev/rules.d/"
    local etcSymdDir="/etc/systemd/system/"
    lsudo cp ${dir}diskMount/99-udisk.rules ${uRulesDir}99-udisk.rules
    lsudo cp ${dir}diskMount/auto*.service $etcSymdDir
    lsudo sed -i "s;^ExecStart=.*;ExecStart=${dir}diskMount/udev_disk_auto_mount.sh %I add;" ${etcSymdDir}autoMount@.service
    lsudo sed -i "s;^ExecStart=.*;ExecStart=${dir}diskMount/udev_disk_auto_mount.sh %I remove;" ${etcSymdDir}autoUmount@.service

    local selfSymdUdevd="${etcSymdDir}systemd-udevd.service"
    lsudo cp /usr/lib/systemd/system/systemd-udevd.service ${selfSymdUdevd}
    lsudo sed -i 's;^MountFlags;#&;' ${selfSymdUdevd}
}

function toolsMisc_httpShare(){
    [ $1 ] || lerror "init diskMount need dir param"
    local dir=$1
    lsudo ln -sf ${dir}httpShare/httpShare.sh /usr/bin/httpShare.sh
}

function initToolsMisc(){
    local dir=${TOOLSDIR}toolsMisc/
    if [ ! -d $dir ];then
        git clone git@github.com:rowanpang/toolsMisc.git $dir
    else
        verbose "$dir exist" 
    fi
    #kvm
    toolsMisc_kvm $dir
    #diskMount
    toolsMisc_diskMount $dir
    #httpShare
    toolsMisc_httpShare $dir
}

function initXXnet(){
    local dir=${TOOLSDIR}xx-net/
    pkgCheckInstall pyOpenSSL
    if [ ! -d $dir ];then
        git clone git@github.com:rowanpang/XX-Net.git $dir
    else
        verbose "$dir exist" 
    fi

    lsudo cp ${dir}code/default/xx_net.sh /etc/init.d/xx_net
    lsudo sed -i "/^PACKAGE_VER_FILE=/ iPACKAGE_PATH=\"${dir}code/\"" /etc/init.d/xx_net
    lsudo chkconfig --add xx_net
}

function initWine(){
    pkgCheckInstall samba-winbind-clients updates 
    pkgCheckInstall wine updates
}

function initWireshark(){
    pkgCheckInstall wireshark-gtk
    pkgCheckInstall wireshark-qt
    [ $? ] && lsudo usermod --append --groups wireshark,usbmon $USER
}

function initGNU(){
    pkgCheckInstall gcc-c++	 #will auto dependence gcc e.g
}

function initRepo(){
    if [ $osVendor == "fedora" ];then
	lsudo dnf --assumeyes install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    fi

    lsudo sed -i "s/^metadate_expire=.*/#&/" /etc/yum.repos.d/*
    lsudo sed -i "$ a metadate_expire=never" /etc/dnf/dnf.conf
}

function initSoft(){
    pkgCheckInstall mplayer rpmfusion-free rpmfusion-free-updates
    pkgCheckInstall kernel-devel
    pkgCheckInstall mediainfo
    pkgCheckInstall nmap
}

function main(){
    callFunc initCheck
    callFunc initRepo
    callFunc initGNU
    callFunc disableSelinux
    callFunc initVim
    callFunc initKeyBoard
    callFunc initNutstore
    callFunc initSynergy
    callFunc initI3wm
    callFunc initToolsMisc
    callFunc initXXnet
    callFunc initWireshark
    callFunc initSoft
}

#main

DEBUG=''
HOMEDIR="/home/$USER/"
ROOTHOME="/root/"
TOOLSDIR="${HOMEDIR}tools/"

[ $1 ] &&  DEBUG='yes'
main
