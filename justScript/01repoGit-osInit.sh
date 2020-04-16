#!/bin/bash

source ./osInitframe/lib.sh

function repoNoteGit(){
    local workDir="$HOME/noteGit" 

    if [ -d $workDir ];then
	:  	#git -C $workDir pull
    else
	git -C $HOME clone git@github.com:rowanpang/noteGit.git
    fi
}

function repoConan(){
    local workDir="$HOME/conan" 

    if [ -d $workDir ];then
	: 	#git -C $workDir pull
    else
	git -C $HOME clone git@git.oschina.net:rowanPang/conan.git
    fi
}

repoNoteGit
repoConan
