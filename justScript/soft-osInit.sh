#!/bin/bash

source ./osInitframe/lib.sh

function initWine(){
    pkgCheckInstall samba-winbind-clients updates
    #pkgCheckInstall wine updates
}

function initWireshark(){
    if [ $(fedoraXlater 31) == "yes" ] ;then
	pkgCheckInstall wireshark
    else
	pkgCheckInstall wireshark-gtk
	pkgCheckInstall wireshark-qt
    fi
    [ $? -eq 0 ] && lsudo usermod --append --groups wireshark,usbmon $USER
}

function miscInit(){
    kern=$(rpm -q kernel)
    kerndevel=${kern/kernel/kernel-devel}
    pkgCheckInstall $kerndevel

    pkgCheckInstall mplayer rpmfusion-free rpmfusion-free-updates
    pkgCheckInstall mediainfo
    pkgCheckInstall nmap
    pkgCheckInstall screen
    pkgCheckInstall meld
    pkgCheckInstall nodejs
    pkgCheckInstall daemonize
    pkgCheckInstall firewall-applet
    pkgCheckInstall lshw
    pkgCheckInstall usbview
    pkgCheckInstall seahorse
    pkgCheckInstall autojump
    pkgCheckInstall mailx
	#autojump use $PROMPT_COMMAND 实现将dir添加到数据库中.
	#j() 是在bash加载时export的func
	#autojump_add_to_database()  也是export 的func
	#数据库: ~/.local/share/autojump/autojump.txt
    pkgCheckInstall autoconf
    pkgCheckInstall autoconf-archive
    pkgCheckInstall automake

	#for kernel build dependence
    pkgCheckInstall asciidoc
}

#for view file through nautilus
function gvfsInit(){
    pkgCheckInstall gvfs-smb
    pkgCheckInstall gvfs-nfs
}

function gftp(){
    pkgCheckInstall gftp
    cfg=$HOME/.gftp/gftprc

    mkdir -p `dirname $cfg`

    #远程服务器中文显示
    if [ -f $cfg ];then
        sed -i 's/remote_charsets=.*/remote_charsets=cp936,gb18303,gbk,gb2312,utf8,gb18030,euc-tw,zh_CN/' $cfg
    else
        echo 'remote_charsets=cp936,gb18303,gbk,gb2312,utf8,gb18030,euc-tw,zh_CN/' > $cfg
    fi
}

function main(){
    gvfsInit
    initWireshark
    miscInit
}

main
