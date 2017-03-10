#!/bin/bash

source ./osInitframe/lib.sh

function initSynergy(){
    local dir=$localdir
    lsudo ln -sf ${dir}synergy.conf /etc/synergy.conf
}

initSynergy
