#!/bin/bash
source ./osInitframe/lib.sh

binDir="$localdir/bin"

#conf="./bash_profile"		    #for test
conf="$HOME/.bash_profile"
conf="$HOME/.bashrc"

if [ `echo "$PATH" | grep -c "$binDir"` -eq 0 ];then
    echo 'PATH=$PATH:'"$binDir" >> $conf
    echo "export PATH" >> $conf

    PATH=$PAHT:$binDir
    export PATH
fi
