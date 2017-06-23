#!/bin/bash

source ./osInitframe/lib.sh

function main(){
    local dir=$localdir
    lsudo ln -sf ${dir}/httpShare.sh /usr/bin/httpShare.sh
}

main
