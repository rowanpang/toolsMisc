#!/bin/bash

source ./osInitframe/lib.sh

function main(){
    pkgCheckInstall tsocks
    if ! [ -x "/usr/bin/tsocks.org" ];then
	lsudo mv /usr/bin/tsocks /usr/bin/tsocks.org
	lsudo cp $localdir/tsocks /usr/bin/tsocks
    fi
    lib="/usr/lib64/libtsocks.so.1.8"
    libbk="${lib}.org"
    

    if [ -e $lib ] && ! [ -e $libbk ];then
	lsudo mv $lib $libbk
	lsudo cp $localdir/libtsocks.so.1.8 $lib
    fi
}

main
