#!/bin/bash
source ./osInitframe//lib.sh

function ssInit(){
    dir=$localdir

    #pkgCheckInstall python-shadowsocks
    pkgCheckUninstall python-shadowsocks
    pkgCheckInstall libsodium-1.0.12-1.fc24 updates

    if ! [ -f /etc/yum.repos.d/_copr_librehat-shadowsocks.repo ];then
	lsudo dnf copr enable librehat/shadowsocks
	lsudo dnf copr disable librehat/shadowsocks
    fi
    pkgCheckInstall shadowsocks-libev.x86_64 librehat-shadowsocks

    method='systemd'

    local svr=shadowsocks-rowan.service
    local timer=shadowsocks-rowan.timer
    if [ $method == 'systemd' ];then
	local socfg="${dir}systemd-${svr}"
	local tocfg="${dir}systemd-${timer}"
	local stcfg="/etc/systemd/system/$svr"	    #service target config
	local ttcfg="/etc/systemd/system/$timer"

	[ -f /etc/cron.d/shadowSocks-update ] && lsudo rm -f /etc/cron.d/shadowSocks-update
	lsudo cp $socfg $stcfg
	lsudo cp $tocfg $ttcfg
	lsudo sed -i "s;\(^ExecStart=\)\S\+$;\1${dir}ssStart.sh;" $stcfg
	[ $? ] && systemctl enable $timer

    else
	#cron,run every minute"
	#journal --identifier CORND   to check log
	lsudo sh -c "cat << EOF > /etc/cron.d/shadowSocks-update
3-59/3 * * * * $USER ${dir}ssStart.sh --checkTime
EOF"
	systemctl disable $timer
    fi



}

ssInit
