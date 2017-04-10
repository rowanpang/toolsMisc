#!/bin/bash
source ./osInitframe//lib.sh

function ssInit(){
    dir=$localdir
    pkgCheckInstall python-shadowsocks
    pkgCheckInstall libsodium

    #cron,run 5 minutes after midn,6,12am ...,everyday"
    #journal --identifier cornd   to check log
    lsudo sh -c "cat << EOF > /etc/cron.d/shadowSocks-update
02 0-23/6 * * * pangwz ${dir}ssStart.sh
EOF"
}

ssInit
