#!/bin/bash

source ./osInitframe/lib.sh

function cryptography(){
    pkgCheckInstall python2-cryptography
    pkgCheckInstall python3-cryptography

    if [ $osVer -eq 26 ];then
	pkgCheckInstall python-fedora-flask
    else
	pkgCheckInstall python-flask
    fi
}

function main(){
    cryptography
}

main
