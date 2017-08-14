#!/bin/bash
source ./osInitframe/lib.sh


bashrc="$HOME/.bashrc"

if [ `grep -c histverify $bashrc` -eq 0 ];then
    sed -i '$ishopt -s histverify' $bashrc
fi

#support svn to stroe passwd by gpg-agent
if [ `grep -c gpg-connect-agent $bashrc` -eq 0 ];then
    sed -i '$igpg-connect-agent /bye' $bashrc
fi
