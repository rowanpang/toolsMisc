#/bin/bash
source ./osInitframe/lib.sh

function initVim(){
    local dir=$localdir
    pkgCheckInstall vim-X11
    pkgCheckInstall vim-enhanced
    pkgCheckInstall ctags
    pkgCheckInstall cscope

    [ -L ${HOMEDIR}.vim ] ||  ln -s $dir ${HOMEDIR}.vim
    lsudo [ -L ${ROOTHOME}.vim ] || lsudo ln -sf $dir ${ROOTHOME}.vim   #for root vim
    lsudo sed  -i 's; \[\s\+.*\]\s\+\&\&\s\+return$;#&;' /etc/profile.d/vim.sh
}

initVim
