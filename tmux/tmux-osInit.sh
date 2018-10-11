#/bin/bash
source ./osInitframe/lib.sh

function baseInit(){
    pkgCheckInstall tmux

    local cfg="$localdir/tmux.conf"
    local cfgTarget="$HOME/.tmux.conf"

    [ -L $cfgTarget ] || ln -s $cfg $cfgTarget
}


function main(){
    baseInit
}

main
