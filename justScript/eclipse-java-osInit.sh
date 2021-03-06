#!/bin/bash

source ./osInitframe/lib.sh

function javaEnv(){
    pkgCheckInstall java-*-openjdk
    pkgCheckInstall java-*-openjdk-devel
    pkgCheckInstall java-*-openjdk-headless
    pkgCheckInstall java-*-openjdk-src

    local eclipseDir="$HOME/workspace/"
    [ -d $eclipseDir ] || mkdir -p $eclipseDir

    local javaWS="$HOME/noteGit/java/eclipseWS/"
    local jWSlink="$eclipseDir/java-eclipse"
    [ -L $jWSlink ] || ln -s $javaWS $jWSlink

    local cWS="$HOME/noteGit/gnu/eclipseWS/"
    local cWSlink="$eclipseDir/c-eclipse"
    [ -L $cWSlink ] || ln -s $cWS $cWSlink

    local pyWS="$HOME/noteGit/python/pycharmWS/"
    local pyWSlink="$eclipseDir/pycharm-py"
    [ -L $pyWSlink ] || ln -s $pyWS $pyWSlink
}

function eclipseIDE(){
    pkgCheckInstall eclipse-platform
    if [ "$USER" == "root" ];then
	return
	#for root user will cause 'Fragment directory should be read only..' error
	#ref https://github.com/eclipse/rt.equinox.p2/blob/master/bundles/  \
	    #org.eclipse.equinox.simpleconfigurator/src/org/eclipse/equinox/ \
	    #internal/simpleconfigurator/utils/SimpleConfiguratorUtils.java
    fi
    pkgCheckInstall eclipse-jdt
    pkgCheckInstall eclipse-cdt
    pkgCheckInstall eclipse-mpc
    pkgCheckInstall maven-eclipse-plugin
    pkgCheckInstall eclipse-m2e-mavenarchiver.noarch
}

function main(){
    javaEnv
#   eclipseIDE
}

main
