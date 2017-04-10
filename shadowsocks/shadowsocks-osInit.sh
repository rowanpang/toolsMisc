#!/bin/bash
source ./osInitframe//lib.sh

function ssInit(){
    pkgCheckInstall python-shadowsocks
    pkgCheckInstall libsodium
}

ssInit
