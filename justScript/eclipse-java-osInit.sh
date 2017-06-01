#!/bin/bash

source ./osInitframe/lib.sh

function javaEnv(){
    pkgCheckInstall java-*-openjdk
    pkgCheckInstall java-*-openjdk-devel
    pkgCheckInstall java-*-openjdk-headless
    pkgCheckInstall java-*-openjdk-src

    local eclipseDir="$HOME/eclipse/"
    local javaWS="$HOME/noteGit/java/eclipseWS/"
    local jWSlink="$eclipseDir/jworkspace"
    [ -d $eclipseDir ] || mkdir -p $eclipseDir
    [ -L $jWSlink ] || ln -s $javaWS $jWSlink
}

function eclipseIDE(){
    pkgCheckInstall eclipse-platform
    pkgCheckInstall eclipse-jdt
    pkgCheckInstall eclipse-cdt
    pkgCheckInstall eclipse-mpc
}

function main(){
    javaEnv
    eclipseIDE
}

main
