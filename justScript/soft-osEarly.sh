#!/bin/bash

source ./osInitframe/lib.sh

function initGNU(){
    pkgCheckInstall gcc-c++	 #will auto dependence gcc e.g
    pkgCheckInstall rpm-build #will auto dependence gcc e.g
    mkdir -p $HOME/rpmbuild
    ln -sf ${localdir}rpmbuild-initbuild.sh  $HOME/rpmbuild/initbuild.sh
}

function main(){
    initGNU
}

main
