#!/bin/bash

source ./osInitframe/lib.sh

function initGNU(){
    pkgCheckInstall gcc-c++	 #will auto dependence gcc e.g
}

function main(){
    initGNU
}

main
