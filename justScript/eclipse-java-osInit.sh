#!/bin/bash

source ./osInitframe/lib.sh

function javaEnv(){
    pkgCheckInstall java-*-openjdk
    pkgCheckInstall java-*-openjdk-devel
    pkgCheckInstall java-*-openjdk-headless
    pkgCheckInstall java-*-openjdk-src
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
