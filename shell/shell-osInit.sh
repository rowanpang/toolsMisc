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
    binDir="$localdir/bin"
    conf="$HOME/.bash_profile"
    conf="$HOME/.bashrc"

    for conf in {"$HOME/.bashrc","$HOME/.zshrc"};do
	if [ -f $conf ];then
	    if [ `echo "$PATH" | grep -c "$binDir"` -eq 0 ];then
		echo 'PATH=$PATH:'"$binDir" >> $conf
		echo "export PATH" >> $conf

		PATH=$PAHT:$binDir
		export PATH
	    fi
	fi
    done
}

function zshInit(){
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

}

bashConf
binPATH
zshInit
