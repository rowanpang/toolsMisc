#!/bin/bash
source ./osInitframe//lib.sh

function ssInit(){
    dir=$localdir
    pkgCheckInstall python-shadowsocks
    pkgCheckInstall libsodium

    #cron,run 5 minutes after midn,6,12am ...,everyday"
    lsudo sh -c "cat << EOF > /etc/cron.d/shadowSocks-update
2 0-23/6 * * * pangwz ${dir}ssStart.sh
EOF"
}

ssInit
