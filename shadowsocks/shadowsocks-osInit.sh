#!/bin/bash
source ./osInitframe//lib.sh

function ssInit(){
    dir=$localdir
    pkgCheckInstall python-shadowsocks
    pkgCheckInstall libsodium

    #cron,run every minute"
    #journal --identifier CORND   to check log
    lsudo sh -c "cat << EOF > /etc/cron.d/shadowSocks-update
0-59/3 * * * * pangwz ${dir}ssStart.sh --checkTime
EOF"
}

ssInit
