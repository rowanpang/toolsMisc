#!/bin/bash

source ./osInitframe/lib.sh

function main(){
    pkgCheckInstall svn
    svn --version --quiet
    lcfg=${localdir}config
    tcfg=$HOME/.subversion/config
    ln -sf $lcfg $tcfg
}

main
