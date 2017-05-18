#!/bin/bash

source ./osInitframe/lib.sh

function baseInit(){
    local dir=$localdir
    if ! [ $(pkgInstalled adobe-release-x86_64) ];then
	lsudo rpm -i ${dir}adobe-release-x86_64-1.0-1.noarch.rpm
    fi

    pkgCheckInstall flash-plugin adobe-linux-x86_64

}

baseInit
