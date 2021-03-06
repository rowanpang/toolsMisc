#!/bin/bash

function pr_info(){
    if [ "$DEBUG" == 'yes' ];then
        echo $@
    fi
}

function pr_warn(){
    #33m,yellow
    echo -e "\033[1;33m""$@""\033[0m"
}

function pr_ok(){
    #32m,green
    echo -e "\033[1;32m""$@""\033[0m"
}

function pr_err(){
    #31m,red
    echo -e "\033[1;31m""$@""\033[0m"
    exit -1
}

function lsudo(){
    echo -e "\033[1;32msudo for:"\""$@"\""\033[0m"
    sudo "$@"
    if [ $? -eq 1 ];then
        echo -e "\033[1;32m""sudo authen error exit -1""\033[0m"
        exit -1
    fi
}

#1,func
#2...,args to func
function callFunc(){
    local func=$1
    shift
    pr_info "=================func:$func in========================"
    $func "$@"
    local ret=$?
    pr_info "=================func:$func finished=================="
    return $ret
}

#$1:pkg to check
function pkgInstalled(){
    local pkg=$1
    rpm -q $pkg 2>&1 >/dev/null
    [ $? -eq 0 ] && echo "yes"
}

#$1,pkg name
#$2,cmd
#$3..enable repos
#return:
    #255:had installed
    #254:when do 'remove' if not install return it
    #205:pkgX uninstall error
    # * :dnf return value
function pkgCheckdoCmd(){
    local pkg=$1
    local cmd=$2
    shift 2
    local isInstalled=$(pkgInstalled $pkg)

    if [ "$isInstalled" -a "$cmd" == "install" ];then
        pr_info "$pkg has been installed,return"
        return 255
    fi

    if [ ! "$isInstalled" -a "$cmd" == "remove" ];then
        pr_info "$pkg has not installed,return"
	return 254
    fi

    local enabledRepo="--enablerepo=fedora --enablerepo=updates "
    for repo in $@;do
	enabledRepo="$enabledRepo --enablerepo=$repo"
    done
    lsudo dnf --assumeyes --disablerepo=* $enabledRepo "$cmd" "$pkg"
    [ $? ] || pr_err "pkg $pkg do $cmd error"
    return $?
}

#$1,pkg name
#$2..enable repos
function pkgCheckInstall(){
    local pkg=$1
    shift
    pkgCheckdoCmd $pkg "install" "$@"
    [ $? == 255 ] || return 0
    return $?
}

#$@:pkgs to install
#return:
    #255: pkgX install error

function pkgsInstall(){
    for pkg in "$@";do
	pkgCheckInstall $pkg
	[ $? ] || return $?
    done
    return $?
}

#1:pkg
function pkgCheckUninstall(){
    local pkg=$1
    shift
    pkgCheckdoCmd $pkg "remove" "$@"
    [ $? == 254 ] || return 0
    return $?
}

#$@:pkgs to uninstall
function pkgsUninstall(){
    for pkg in "$@";do
	pkgCheckUninstall $pkg
	[ $? ] || return $?
    done
    return $?
}

function netRPMInstall(){
    pkgName=$1
    pkgUrl=$2
    if ! [ "$(pkgInstalled $pkgName)" ];then
        pr_info "installing $pkgName"
        lsudo yum install $pkgUrl
    else
	pr_info "$pkgName installed"
    fi
}

function isdisable(){
    dir=$localdir
    if [ -f $dir/disable ] ;then
	pr_warn "$dir disable,exit -5"
	exit -5;
    fi
}

function libInit(){
    if [ -r /etc/redhat-release ];then
        case $(cat /etc/redhat-release) in
            Fedora*):
                osVendor=fedora
                osVer=$(rpm --eval=%fedora)
                ;;
        esac
    fi

    program=$0
    pdir=`dirname $program | sed 's;^\./;;'`
    localdir="$PWD/${pdir}/"

    DEBUG="yes"
    HOMEDIR="$HOME/"
    ROOTHOME="/root/"
    i3configSelected="$PWD/i3/config-v4.12"
    dlink=$(ip route | grep default |		    \
	    awk '{
		    i=1;
		    while(i<NF){
			if($i=="dev"){
			    print $(i+1)
			};
			i++
		    }
		}')
    dip=$(ip a s $dlink | grep 'inet ' | awk '{print $2}' | \
	    awk 'BEGIN{ FS="/" };
		{
		    print $1
		}')
}

function fedoraXlater(){
    ver=$1
    if [ $osVendor == "fedora" -a $osVer -ge $ver ];then
	echo "yes" ; return  0
    else
	echo "no"  ; return  -1
    fi
}

function frameOsInit(){
    libInit
    isdisable

    [ -d $HOME/Pictures ] || mkdir -p $HOME/Pictures
}

frameOsInit
