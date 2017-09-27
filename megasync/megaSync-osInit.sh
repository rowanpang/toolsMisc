#!/bin/bash

source ./osInitframe/lib.sh

function main(){
    hosts='/etc/hosts'
    if [ $(grep -c 'mega.nz' $hosts) -eq 0 ];then
	lsudo sed -i "/::1/a154.53.224.166 mega.nz" $hosts
    fi

    pkgName="megasync"
    pkg="https://mega.nz/linux/MEGAsync/Fedora_${osVer}/$(uname -m)/$pkgName-Fedora_${osVer}.x86_64.rpm"
    netRPMInstall $pkgName $pkg

    #pkgName="nautilus-megasync"
    #pkg="https://mega.nz/linux/MEGAsync/Fedora_${osVer}/$(uname -m)/$pkgName-Fedora_${osVer}.x86_64.rpm"
    #netRPMInstall $pkgName $pkg
}

main
