#!/bin/bash

source ./osInitframe/lib.sh

function cryptography(){
    pkgCheckInstall python2-cryptography
    pkgCheckInstall python3-cryptography
}

function main(){
    cryptography
}

main
