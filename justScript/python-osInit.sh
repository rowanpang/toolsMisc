#!/bin/bash

source ./osInitframe/lib.sh

function cryptography(){

    if [ $osVer -eq 26 ];then
	pkgCheckInstall python-fedora-flask
    else
    	if [ $(fedoraXlater 31) == "yes" ];then
		pkgCheckInstall python3-flask
	else
		pkgCheckInstall python-flask
	fi
    fi


    if [ $(fedoraXlater 31) == "yes" ];then
	pkgCheckInstall python3-autopep8
        pkgCheckInstall python3-cryptography
        pkgCheckInstall python3-pycodestyle
        pkgCheckInstall python3-autopep8
    else
	pkgCheckInstall python2-autopep8
	pkgCheckInstall python2-cryptography
        pkgCheckInstall python2-pycodestyle
    fi
}

function main(){
    cryptography
}

main
