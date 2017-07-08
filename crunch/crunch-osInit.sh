#!/bin/bash
# dict generator

source ./osInitframe/lib.sh

function baseInit(){
    local dir=$localdir

    local repofile="home:zhonghuaren.repo"
    local repoName="home_zhonghuaren"
    if ! [ -s /etc/yum.repos.d/$repofile ];then
	lsudo dnf config-manager --add-repo http://ftp.gwdg.de/pub/opensuse/repositories/home:/zhonghuaren/Fedora_24/$repofile
    fi

    lsudo dnf config-manager --set-disabled $repoName

    pkgCheckInstall crunch $repoName
}

baseInit
