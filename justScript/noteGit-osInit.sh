#!/bin/bash

source ./osInitframe/lib.sh

function baseClone(){
    local workDir="$HOME/noteGit" 

    if [ -d $workDir ];then
	git -C $workDir pull
    else
	git -C $HOME clone git@github.com:rowanpang/noteGit.git
    fi
}

baseClone
