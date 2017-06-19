#!/bin/bash

source ./osInitframe/lib.sh

function javaEnv(){
    pkgCheckInstall java-*-openjdk
    pkgCheckInstall java-*-openjdk-devel
    pkgCheckInstall java-*-openjdk-headless
    pkgCheckInstall java-*-openjdk-src

    local eclipseDir="$HOME/eclipse/"
    [ -d $eclipseDir ] || mkdir -p $eclipseDir

    local javaWS="$HOME/noteGit/java/eclipseWS/"
    local jWSlink="$eclipseDir/jworkspace"
    [ -L $jWSlink ] || ln -s $javaWS $jWSlink

    local cWS="$HOME/noteGit/gnu/eclipseWS/"
    local cWSlink="$eclipseDir/cworkspace"
    [ -L $cWSlink ] || ln -s $cWS $cWSlink
}

function eclipseIDE(){
    pkgCheckInstall eclipse-platform
    pkgCheckInstall eclipse-jdt
    pkgCheckInstall eclipse-cdt
    pkgCheckInstall eclipse-mpc

    #maven manager 
    pkgCheckInstall maven-eclipse-plugin
    pkgCheckInstall eclipse-m2e-mavenarchiver.noarch
}

function main(){
    javaEnv
    eclipseIDE
}

main
