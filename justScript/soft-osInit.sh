#!/bin/bash

source ./osInitframe/lib.sh

function initWine(){
    pkgCheckInstall samba-winbind-clients updates
    #pkgCheckInstall wine updates
}

function initWireshark(){
    pkgCheckInstall wireshark-gtk
    pkgCheckInstall wireshark-qt
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
    pkgCheckInstall seahorse
    pkgCheckInstall autojump
	#autojump use $PROMPT_COMMAND 实现将dir添加到数据库中.
	#j() 是在bash加载时export的func
	#autojump_add_to_database()  也是export 的func
	#数据库: ~/.local/share/autojump/autojump.txt
}

function main(){
    initWireshark
    miscInit
}

main
