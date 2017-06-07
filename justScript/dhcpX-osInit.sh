#!/bin/bash

source ./osInitframe/lib.sh

function pkgInstall(){
    pkgCheckInstall dhcp-client
    pkgCheckInstall dhcp-server
}

function main(){
    pkgInstall
}

main
