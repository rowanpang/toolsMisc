#!/bin/bash

source ./osInitframe/lib.sh

function pkgInstall(){
    local dir="${localdir}/"
    local confFile="$HOME/.goldendict/config"
    local defConf="${dir}config-default"
    pkgCheckInstall goldendict

    [ -d $HOME/.goldendict ] || mkdir -p $HOME/.goldendict
    cp $defConf $confFile

    sed -i "s;/home/pangwz/tools/;${localdir};" $confFile
}

function repoInit(){
    local dir="${localdir}/dictRepo/"
    cd $dir
    tar -xjf stardict-oxford-gb-formated-2.4.2.tar.bz2
    tar -xjf stardict-langdao-ce-gb-2.4.2.tar.bz2
    tar -xjf stardict-langdao-ec-gb-2.4.2.tar.bz2
    cd -
}

function main(){
    pkgInstall
    repoInit
}

main
