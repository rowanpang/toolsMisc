#!/bin/bash

source ./osInitframe/lib.sh

function pkgInstall(){
    pkgCheckInstall sysstat
    pkgCheckInstall nmon
}

function main(){
    pkgInstall
}

main
