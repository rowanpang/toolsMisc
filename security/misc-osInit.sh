#!/bin/bash

source ./osInitframe/lib.sh
function tripwireInit(){
    local dir=$localdir
    pkgCheckInstall tripwire

    cp ${dir}/twpol.cfg /etc/tripwire/twpol.txt
}

function main(){
    #pkgCheckInstall hydra
    tripwireInit
    true
}

main
