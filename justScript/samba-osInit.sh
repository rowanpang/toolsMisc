#!/bin/bash

source ./osInitframe/lib.sh

function pkgInstall(){
    pkgCheckInstall samba.x86_64
    pkgCheckInstall samba-client.x86_64
    pkgCheckInstall samba-client-libs.x86_64
    pkgCheckInstall samba-common.noarch
    pkgCheckInstall samba-common-libs.x86_64
    pkgCheckInstall samba-common-tools.x86_64
    pkgCheckInstall samba-libs.x86_64

    cfgl="${localdir}samba-smb.conf"
    cfgt="/etc/samba/smb.conf"
    rm -f $cfgt
    lsudo ln -sf $cfgl $cfgt

    smbUser="$USER"
    local isExist=`lsudo pdbedit -L | grep $smbUser`

    local smbdir='/home/smbPublic'
    [ -d $smbdir ] || mkdir -p $smbdir

    if [ "$isExist" ];then
	echo "smbuser:$smbUser is exist"
    else
	lsudo smbpasswd -a $smbUser << EOF
qqqqqq
qqqqqq
EOF
    fi

}

function main(){
    pkgInstall
}

main
