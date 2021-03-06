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
	# [ -f /etc/yum.repos.d/FZUG.repo ] || lsudo dnf config-manager --add-repo=http://repo.fdzh.org/FZUG/FZUG.repo 	#not used FZUG rowanPang 2019.12.18

	dnf --refresh makecache
    fi

}

#$1,scripts regex to exec
function doScripts(){
    local reg=$1
    for script in $(find ./ -mindepth 2 -name "$reg" | sort); do
	pr_info "do script $script"
	$script
	ret=$?
	pr_info "---------------end ret:$ret ------------------"

	case $ret in
		0)
			:;;
		251) 			#script disabled
			:;;
		*)
			msg="$script run error, exit $ret"
			pr_err $msg
	esac
    done
    pr_ok "all script finished"
}

function initCheck(){
    disableSelinux
    initRepo
    local reg='*-osEarly.sh'
    doScripts "$reg"

    local who=`whoami`
    [ "$who" == "$USER" ] || pr_err "effective user:$who is not login user:$USER"
    [ -f ${HOMEDIR}.gitconfig ] || pr_err " prepare .gitconfig first,exit"
    [ -f ${HOMEDIR}.ssh/id_rsa ] || pr_err "prepare ssh key first,exit"

}

function main(){
    git submodule init
    git submodule update
    #callFunc initCheck
    local reg='*-osInit.sh'
    doScripts "$reg"
}

#main
[ $1 ] &&  DEBUG='yes'
main
