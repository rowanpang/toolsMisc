#!/bin/bash
source	./osInitframe/lib.sh

function disableSelinux(){
    $(selinuxenabled)
    if [ $? -eq 0 ];then
        lsudo setenforce 0
        lsudo sed -i 's;SELINUX=enforcing;SELINUX=disabled;' /etc/selinux/config
    fi
}

function initRepo(){
    if [ $osVendor == "fedora" -a $osVer -ge 24 ];then
	if ! [ $(pkgInstalled rpmfusion-free-release) ];then
	    lsudo dnf --assumeyes install   \
		https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${osVer}.noarch.rpm
	fi

	if ! [ $(pkgInstalled rpmfusion-nonfree-release) ];then
	    lsudo dnf --assumeyes install    \
		https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${osVer}.noarch.rpm
	fi

	lsudo sed -i "s/^metadata_expire=.*/#&/" /etc/yum.repos.d/*
	lsudo dnf config-manager --set-disabled rpmfusion-*
	lsudo dnf config-manager --set-enable fedora
	lsudo dnf config-manager --set-enable updates

	[ $(cat /etc/dnf/dnf.conf | grep -c 'expire=1000d') -ge 1 ] || lsudo sed -i "$ a metadata_expire=1000d" /etc/dnf/dnf.conf
	[ $(cat /etc/dnf/dnf.conf | grep -c 'keepcache=true') -ge 1 ] || lsudo sed -i "$ a keepcache=true" /etc/dnf/dnf.conf
    fi

    [ -f /etc/yum.repos.d/FZUG.repo ] || lsudo dnf config-manager --add-repo=http://repo.fdzh.org/FZUG/FZUG.repo
}

#$1,scripts regex to exec
function doScripts(){
    local reg=$1
    for script in $(find ./ -mindepth 2 -name "$reg" | sort);do
	pr_info "do script $script"
	$script
	ret=$?
	pr_info "---------------end ret:$ret ------------------"
	[ $ret -eq 0 ] || pr_err "script $script error"
    done
}

function initCheck(){
    disableSelinux
    initRepo
    local reg='*-osEarly.sh'
    doScripts "$reg"

    local who=`whoami`
    [ "$who" == "$USER" ] || lerror "effective user:$who is not login user:$USER"
    [ -f ${HOMEDIR}.gitconfig ] || lerror " prepare .gitconfig first,exit"
    [ -f ${HOMEDIR}.ssh/id_rsa ] || lerror "prepare ssh key first,exit"

}

function main(){
    callFunc initCheck
    local reg='*-osInit.sh'
    doScripts "$reg"
}

#main
[ $1 ] &&  DEBUG='yes'
main
