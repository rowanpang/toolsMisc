#!/bin/bash

source ./osInitframe/lib.sh

function main(){
    local dir=$local
    lsudo ln -sf ${dir}/httpShare.sh /usr/bin/httpShare.sh
}

main
