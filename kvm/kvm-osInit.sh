#!/bin/bash
source ./osInitframe/lib.sh

function addBridgeAndSlave(){
    local bridgeName=$1
    local slave=$2
    local i3StatCfg="$HOME/.config/i3status/config"	    #remenber modify

    local bridgeConName=$bridgeName
    if [ $(brctl show | grep -c $bridgeName) -eq 0 ];then
        pr_info "add bridge con $bridgeConName"
        nmcli connection add ifname $bridgeName con-name $bridgeConName type bridge
	nmcli connection modify $bridgeConName connection.autoconnect-slaves 1
	nmcli connection modify $bridgeConName ipv6.method ignore
	nmcli connection modify $bridgeConName bridge.stp no
        nmcli connection up $bridgeConName
    fi

    if [ "$slave" ];then
	local slaveConName="brSlave-${bridgeName#br-}-${slave}"
	if [ $(nmcli connection | grep -c $slaveConName) -eq 0 ];then
	    pr_info "add slave $slave to $bridgeName and make connection $slaveConName"
	    nmcli connection add ifname ${slave} con-name $slaveConName type  \
				    bridge-slave master $bridgeName
	    nmcli connection up $slaveConName
	fi
    fi
}

function br-sec(){
    local bridgeName="br-sec"
    local dlink=`echo $(ip link | grep enp | awk 'BEGIN{FS=":"};{print $2}')`
    local slave="enp3s0"
    local slave=$dlink
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
    sed -i "s;\(<hostname>\).*\(</hostname>\);\1${HOSTNAME%.*}\2;" $lancfg

    $cmd -n $lan
    virsh -c qemu:///system net-autostart $lan
}

function usbNetUdev(){
    local dir=$localdir
    local uRulesDir="/etc/udev/rules.d/"
    local rfile="99-usbNetUdev.rules"
    lsudo cp ${dir}${rfile} ${uRulesDir}

    rfile="99-pciNetUdev.rules"
    lsudo cp ${dir}${rfile} ${uRulesDir}
}

function ldnsmasq() {
    local cfg1=${dir}NetworkManager.conf
    local cfg2=${dir}dnsmasq.conf

    lsudo ln -sf $cfg1 /etc/NetworkManager/
    lsudo ln -sf $cfg2 /etc/NetworkManager/dnsmasq.d/
}

function vncInit(){
    pkgCheckInstall tigervnc
    pkgCheckInstall tigervnc-server
    sOrg="/usr/lib/systemd/system/vncserver@.service"

    #for root user enable vncserver :1 and :2
    vncCfg="root:1,2"
    for cfg in $vncCfg;do
	usr=${cfg%%:*}
	displays=${cfg##*:}
	echo $usr $displays

	sNew="/etc/systemd/system/vncserver-${usr}@.service"
	lsudo cp $sOrg $sNew
	homedir=`grep ^${usr} /etc/passwd | awk 'BEGIN{FS=":"}{print $6}'`
	lsudo sed -i -e "s/=<USER>/=${usr}/" -e "s#=/home/<USER>#=${homedir}#" $sNew

	for display in `echo $displays | sed 's/,/ /'`;do
	    echo $display
	    #systemctl daemon-reload
	    #systemctl enable vncserver-${usr}@:${displayName}.service
	    #systemctl start vncserver-${usr}@:${displayName}.service
	done
    done

}

function baseInit(){
    local dir=$localdir
    pkgCheckInstall virt-manager
    pkgCheckInstall iptraf-ng
    pkgCheckInstall bmon
    pkgCheckInstall libvirt-client
    [ $? -eq 0 ] && lsudo usermod --append --groups kvm,qemu,libvirt $USER

    local kvmDir="${HOMEDIR}vm-iso/"
    [ -d $kvmDir ] || mkdir -p $kvmDir
    ln -rsf ${dir}fw24.xml   ${dir}template.xml
    ln -sf  ${dir}vmStart.sh ${kvmDir}vmStart.sh
    ln -sf  ${dir}isoMK.sh   ${kvmDir}isoMK.sh
    ln -sf  ${dir}vmUsb.sh   ${kvmDir}vmUsb.sh
    ln -sf  ${dir}vmNet.sh   ${kvmDir}vmNet.sh

    pkgCheckInstall bridge-utils
    pkgCheckInstall NetworkManager

    vncInit

    br-wan
    br-sec
    br-kvmlan
    ldnsmasq
    usbNetUdev
}

baseInit
