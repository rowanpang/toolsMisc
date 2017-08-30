#!/bin/bash

source ./osInitframe/lib.sh

function main(){
    pkgCheckInstall tsocks

    [ -d $HOME/.tsocks ] || mkdir -p $HOME/.tsocks

    if ! [ -x "/usr/bin/tsocks.org" ];then
	lsudo mv /usr/bin/tsocks /usr/bin/tsocks.org
    fi
    lsudo cp -rf $localdir/tsocks /usr/bin/tsocks

    lib="/usr/lib64/libtsocks.so.1.8"
    libbk="${lib}.org"
    if [ -e $lib ] && ! [ -e $libbk ];then
	lsudo mv $lib $libbk
    fi
    lsudo cp -rf $localdir/libtsocks.so.1.8 $lib

    cp -rf $localdir/tsocks.conf $HOME/.tsocks/conf
}

main
