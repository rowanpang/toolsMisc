#!/bin/bash

source ./osInitframe/lib.sh

function pkgInstall(){
    local dir=$localdir

    pkgCheckInstall tftp
    pkgCheckInstall tftp-server
    pkgCheckInstall vsftpd
    pkgCheckInstall syslinux-tftpboot.noarch

    local wkdir="/var/lib/tftpboot/"
    [ -s /tftpboot/ ] && wkdir="/tftpboot/"

    local cfgdir="${wkdir}pxelinux.cfg/"
    [ -d ${cfgdir} ] || lsudo mkdir -p "$cfgdir"
    lsudo cp ${dir}pxelinux.cfg ${cfgdir}default

    local imgdir="${wkdir}syslinux/"
    [ -d ${imgdir} ] || lsudo mkdir -p $imgdir
}

function main(){
    pkgInstall
}

main
