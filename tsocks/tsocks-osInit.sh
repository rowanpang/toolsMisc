#!/bin/bash

source ./osInitframe/lib.sh

function main(){
    pkgCheckInstall tsocks
    if ! [ -x "/usr/bin/tsocks.org" ];then
	lsudo mv /usr/bin/tsocks /usr/bin/tsocks.org
	lsudo cp $localdir/tsocks /usr/bin/tsocks
    fi
}

main
