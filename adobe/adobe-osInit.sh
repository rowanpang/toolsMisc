#!/bin/bash

source ./osInitframe/lib.sh

function baseInit(){
    local dir=$localdir
    if ! [ $(pkgInstalled adobe-release-x86_64) ];then
	lsudo rpm -i ${dir}adobe-release-x86_64-1.0-1.noarch.rpm
    fi
    if ! [ $(pkgInstalled flash-plugin) ];then
	lsudo rpm -i ${dir}flash-player-npapi-32.0.0.171-release.x86_64.rpm
    fi

    lsudo dnf config-manager --set-disabled adobe-linux-x86_64
    pkgCheckInstall flash-plugin adobe-linux-x86_64
}

function main(){
    local dir=$localdir
    if [ -f $dir/disable ];then
	pr_warn "adobe disable return "
	return
    fi

    baseInit
}

main

