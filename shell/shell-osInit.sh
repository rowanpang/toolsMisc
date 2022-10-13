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

function bashit(){
    git clone --depth=1 https://github.com/Bash-it/bash-it.git $HOME/.bash_it
    $HOME/.bash_it/install.sh
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

    conf="${HOME}/.zshrc"
    if [ -f $conf ];then
	if [ `cat $conf | grep -c "$binDir"` -eq 0 ];then
	    sed -i "2s;^PATH=\(\S\+\);PATH=$binDir:\1;" $conf
	fi
    fi

    PATH="$PATH:$binDir"
    export PATH
}

function zshInit(){
    pkgCheckInstall zsh
    pkgCheckInstall sqlite		    #needed by zsh for auto complete
    pkgCheckInstall util-linux-user	    #for chsh cmd
    if command -v zsh &>/dev/null;then
	chsh -s /bin/zsh
    fi

    #oMyZsh
    if ! [ -d $HOME/.oh-my-zsh ];then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
    rcT="$HOME/.zshrc"
    rc="$localdir/zshrc"
    #ln -sf $rc $rcT
    cp $rc $rcT
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

function hkfw(){
	cronsh=/etc/cron.d/1hkfw
	cat << EOF > $cronsh
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
* * * * * root sh ${localdir}/bin/hkfw.sh
EOF
}

function main(){
    pkgCheckInstall thefuck
    if [ $osVendor == "fedora" -a $osVer -ge 31 ];then
        if [ `dnf list copr | grep -c fasd` -lt 1 ];then
            dnf copr enable rdnetto/fasd
        fi
    fi
    pkgCheckInstall fasd

    bashConf
    bashit
    zshInit
    binPATH
    sofwareInit
    hkfw

    for f in `ls ${localdir}/shell-osInit.d/*.oi`;do
        bash $f ${localdir}
    done
}

main
