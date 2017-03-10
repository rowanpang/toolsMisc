#/bin/bash
source ./osInitframe/lib.sh

function initVim(){
    local dir=$localdir
    pkgCheckInstall vim-X11
    pkgCheckInstall vim-enhanced
    pkgCheckInstall ctags
    pkgCheckInstall cscope

    ln -snf $dir ${HOMEDIR}.vim
    lsudo ln -snf $dir ${ROOTHOME}.vim   #for root vim
    lsudo sed  -i 's; \[\s\+.*\]\s\+\&\&\s\+return$;#&;' /etc/profile.d/vim.sh
}

initVim
