#!/bin/bash
source	./osInitframe/lib.sh

function disableSelinux(){
    if [ `selinuxenabled` ];then 
        lsudo setenforce 0
        lsudo sed -i 's;SELINUX=enforcing;SELINUX=disabled;' /etc/selinux/config
    fi
}

function initRepo(){
    if [ $osVendor == "fedora" -a $osVer -ge 24 ];then
	if ! [ $(pkgInstalled rpmfusion-free-release) ];then
	    lsudo dnf --assumeyes install   \
		https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm		 
	fi

	if ! [ $(pkgInstalled rpmfusion-nonfree-release) ];then
	    lsudo dnf --assumeyes	    \
		https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	fi

	lsudo sed -i "s/^metadate_expire=.*/#&/" /etc/yum.repos.d/*
	[ $(cat /etc/dnf/dnf.conf | grep -c 'expire=1000d') -ge 1 ] || lsudo sed -i "$ a metadate_expire=1000d" /etc/dnf/dnf.conf
    fi
}

function initCheck(){
    disableSelinux
    initRepo
    local who=`whoami`
    [ "$who" == "$USER" ] || lerror "effective user:$who is not login user:$USER"
    [ -f ${HOMEDIR}.gitconfig ] || lerror " prepare .gitconfig first,exit" 
    [ -f ${HOMEDIR}.ssh/id_rsa ] || lerror "prepare ssh key first,exit"

}


function main(){
    callFunc initCheck

    for script in $(find ./ -mindepth 2 -name '*-osInit.sh');do
	pr_info "do script $script"
	$script
	pr_info "-------------------end------------------"
    done
}

#main
[ $1 ] &&  DEBUG='yes'
main
