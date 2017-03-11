#!/bin/bash

source ./osInitframe/lib.sh

function baseInit(){
    dir=$localdir
    ln -sf ${dir}gitconfig ~/.gitconfig
}

baseInit
