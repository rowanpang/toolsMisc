#!/bin/bash

source ./osInitframe/lib.sh

function pkgInstall(){
    local dir="${localdir}/"
    local confFile="$HOME/.goldendict/config"
    local defConf="${dir}config-default"
    pkgCheckInstall goldendict

    if ! [ -s $confFile ];then
	cp $defConf $confFile
    fi

    sed -i "s;/home/pangwz/tools/;${localdir};" $confFile
}

function repoInit(){
    local dir="${localdir}/dictRepo/"
    cd $dir
    tar -xjf stardict-oxford-gb-formated-2.4.2.tar.bz2
    cd ../
}

function main(){
    pkgInstall
    repoInit
}

main
