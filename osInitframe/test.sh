#!/bin/bash
DEBUG="yes"
source ./lib.sh
echo "$osVendor"
echo "$osVer"

echo -en "pkg bash is installed:\t"
pkgInstalled bash
echo -en "pkg bashrc is installed:\t"
pkgInstalled bashrc
echo

pkgCheckUninstall bashrc
pkgCheckInstall bash
pkgsUninstall bashrc lsms
pkgsInstall bash terminator

function func(){
    echo "func in $0,args: $@"
}

callFunc func adsf
