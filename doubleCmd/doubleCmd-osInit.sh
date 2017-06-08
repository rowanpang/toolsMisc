#!/bin/bash

source ./osInitframe/lib.sh

function baseInit(){
    local dir=$localdir

    local repofile="home:Alexx2000.repo"
    local repoName="home_Alexx2000"
    if ! [ -s /etc/yum.repos.d/$repofile ];then
	lsudo dnf config-manager --add-repo http://download.opensuse.org/repositories/home:Alexx2000/Fedora_24/$repofile
    fi

    lsudo dnf config-manager --set-disabled $repoName
    pkgCheckInstall doublecmd-gtk $repoName

    local ret=$?
    if [ $ret == 0 ];then	    #first install ok. reset configfile
	local confDir="$HOME/.config/doublecmd/"
	local conf="${localdir}doublecmd.xml"
	local hotKey="${localdir}shortcuts.scf"

	lsudo cp $conf $confDir
	lsudo cp $hotKey $confDir
    fi
}

baseInit
