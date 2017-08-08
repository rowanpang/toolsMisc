#!/bin/bash
source ./osInitframe/lib.sh


bashrc="$HOME/.bashrc"
if [ `grep -c histverify $bashrc` -eq 0 ];then
    sed -i '$ishopt -s histverify' $bashrc
fi
