#!/bin/bash

source ./osInitframe/lib.sh

function pkgInstall(){
    pkgCheckInstall tftp
    pkgCheckInstall tftp-server
    pkgCheckInstall syslinux-tftpboot.noarch

}

function main(){
    pkgInstall
}

main
