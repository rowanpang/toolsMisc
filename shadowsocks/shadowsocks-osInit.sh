#!/bin/bash
source ./osInitframe//lib.sh

function ssInit(){
    dir=$localdir

    #pkgCheckInstall python-shadowsocks
    pkgCheckUninstall python-shadowsocks
    pkgCheckInstall libsodium-1.0.12-1.fc24 updates

    lsudo dnf copr enable librehatr/shadowsocks
    lsudo dnf copr disable librehatr/shadowsocks
    pkgCheckInstall shadowsocks-libev.x86_64 librehat-shadowsocks

    #cron,run every minute"
    #journal --identifier CORND   to check log
    lsudo sh -c "cat << EOF > /etc/cron.d/shadowSocks-update
3-59/3 * * * * pangwz ${dir}ssStart.sh --checkTime
EOF"
}

ssInit
