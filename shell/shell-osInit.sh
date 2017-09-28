#!/bin/bash
source ./osInitframe/lib.sh

function bashConf(){
    bashrc="$HOME/.bashrc"

    if [ `grep -c histverify $bashrc` -eq 0 ];then
	sed -i '$ishopt -s histverify' $bashrc
    fi

    #support svn to stroe passwd by gpg-agent
    if [ `grep -c gpg-connect-agent $bashrc` -eq 0 ];then
	sed -i '$igpg-connect-agent /bye' $bashrc
    fi

    if [ `grep -c SVN_EDITOR $bashrc` -eq 0 ];then
	sed -i '$iexport SVN_EDITOR=vim' $bashrc
    fi
}

function binPATH(){
    binDir="${localdir}bin"
    conf="$HOME/.bash_profile"
    conf="$HOME/.bashrc"
    if [ -f $conf ];then
	if [ `cat $conf | grep -c "$binDir"` -eq 0 ];then
	    echo 'PATH=$PATH:'"$binDir" >> $conf
	    echo "export PATH" >> $conf
	fi
    fi

    conf="${localdir}zshrc"
    if [ -f $conf ];then
	if [ `cat $conf | grep -c "$binDir"` -eq 0 ];then
	    sed -i "2s;^PATH=\(\S\+\);PATH=$binDir:\1;" $conf
	fi
    fi

    PATH="$PATH:$binDir"
    export PATH
}

function zshInit(){
    pkgCheckInstall thefuck
    pkgCheckInstall fasd
    pkgCheckInstall zsh
    pkgCheckInstall util-linux-user	#for chsh cmd
    if command -v zsh &>/dev/null;then
	chsh -s /bin/zsh
    fi

    #oMyZsh
    if ! [ -d $HOME/.oh-my-zsh ];then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
    rcT="$HOME/.zshrc"
    rc="$localdir/zshrc"
    ln -sf $rc $rcT
    lsudo useradd -D -s '/usr/bin/zsh'	    #chang the default shell when useradd

    #root user
    if [ "$USER" != 'root' ];then
	lsudo chsh -s /bin/zsh root
	lsudo ln -sf  $rc /root/.zshrc
	lsudo ln -sf /home/pangwz/.oh-my-zsh/   /root/.oh-my-zsh
    fi

    #them
    th="${localdir}steeef-rowan.zsh-theme"
    tht="$HOME/.oh-my-zsh/themes/"
    ln -sf $th $tht
}

function sofwareInit(){
    pkgCheckInstall ansifilter
}

bashConf
zshInit
binPATH
sofwareInit
