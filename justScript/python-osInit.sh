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

    pkgCheckInstall python2-pycodestyle
    pkgCheckInstall python-pep8

    if [ $(fedoraXlater 31) == "yes" ];then
	pkgCheckInstall python3-autopep8
    else
	pkgCheckInstall python2-autopep8
    fi
}

function main(){
    cryptography
}

main
