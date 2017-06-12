#!/bin/bash

source ./osInitframe/lib.sh

function pkgInstall(){
    local dir=$localdir

    pkgCheckInstall tftp
    pkgCheckInstall tftp-server
    pkgCheckInstall syslinux-tftpboot.noarch

    local wkdir="/var/lib/tftpboot/"
    [ -s /tftpboot/ ] && wkdir="/tftpboot/"

    local cfgdir="${wkdir}pexlinux.cfg/"
    [ -d ${cfgdir} ] || lsudo mkdir -p $cfgdir
    lsudo cp ${dir}pxelinux.cfg ${cfgdir}default
}

function main(){
    pkgInstall
}

main
