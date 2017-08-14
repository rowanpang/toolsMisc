#!/bin/bash

source ./osInitframe/lib.sh

function main(){
    pkg=${localdir}megasync-Fedora_24.x86_64.rpm
    [ '$(pkgInstalled megasync)' ] || lsudo rpm -i $pkg
}

main
