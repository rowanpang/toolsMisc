#/bin/bash
source ./osInitframe/lib.sh

function initYCM(){
    local dir=$localdir
    git -C ${dir}/youcompleteme submodule update --recursive

    ycmbuild="${dir}/plugged/youcompleteme/install.py"
    chkFile='/tmp/vim.ycm.build.check.KWkD'

    if ! [ -f $chkFile ];then
	$ycmbuild
	touch $chkFile
    fi
}

function initVim(){
    local dir=$localdir
    pkgCheckInstall vim-X11
    pkgCheckInstall vim-enhanced
    pkgCheckInstall ctags
    pkgCheckInstall cscope
    pkgCheckInstall gotags

    ln -snf $dir ${HOMEDIR}/.vim
    if [ "$USER" != 'root' ];then
	lsudo ln -snf $dir ${ROOTHOME}/.vim   #for root vim
    fi
    lsudo sed  -i 's; \[\s\+.*\]\s\+\&\&\s\+return$;#&;' /etc/profile.d/vim.sh

    pkgsInstall clang llvm automake gcc gcc-c++ cmake python-devel  	#for ycm dependence
    pkgsInstall golang

    #fix deps for ack plugin
    pkgCheckInstall ack
    pkgCheckInstall the_silver_searcher

    vim +PlugInstall +qa    #install plugin and exit
}

function main(){
    initVim
    initYCM
}

main
