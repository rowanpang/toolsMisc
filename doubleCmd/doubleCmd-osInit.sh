#!/bin/bash

source ./osInitframe/lib.sh

function baseInit(){
    local dir=$localdir

    local repofile="home:Alexx2000.repo"
    local repoName="home_Alexx2000"
    if ! [ -s /etc/yum.repos.d/$repofile ];then
	lsudo dnf config-manager --add-repo http://download.opensuse.org/repositories/home:Alexx2000/Fedora_${osVer}/$repofile
    fi

    lsudo dnf config-manager --set-disabled $repoName
    local hasInstalled=$(pkgInstalled $repoName)

    pkgCheckInstall doublecmd-gtk $repoName
    pkgCheckInstall trash-cli				    #for manage trash can. exp: /home/pangwz/.local/share/Trash/files/*

    if ! [ "$hasInstalled" ];then	    #first install ok. reset configfile
	local confDir="$HOME/.config/doublecmd/"
	local conf="${localdir}doublecmd.xml"
	local hotKey="${localdir}shortcuts.scf"

	[ -d $confDir ]  || mkdir $confDir
	lsudo cp $conf $confDir
	lsudo cp $hotKey $confDir
    fi
}

function main() {
    local dir=$localdir
    if [ -f $dir/disable ];then
	pr_warn "$dir disable return "
	return
    fi

    baseInit
}

main
