#!/bin/bash

source ./osInitframe/lib.sh

function initWine(){
    pkgCheckInstall samba-winbind-clients updates 
    pkgCheckInstall wine updates
}

function initWireshark(){
    pkgCheckInstall wireshark-gtk
    pkgCheckInstall wireshark-qt
    [ $? -eq 0 ] && lsudo usermod --append --groups wireshark,usbmon $USER
}

function initGNU(){
    pkgCheckInstall gcc-c++	 #will auto dependence gcc e.g
}

function miscInit(){
    pkgCheckInstall mplayer rpmfusion-free rpmfusion-free-updates
    pkgCheckInstall kernel-devel
    pkgCheckInstall mediainfo
    pkgCheckInstall nmap
    pkgCheckInstall meld 
    pkgCheckInstall autojump
	#autojump use $PROMPT_COMMAND 实现将dir添加到数据库中.
	#j() 是在bash加载时export的func
	#autojump_add_to_database()  也是export 的func
	#数据库: ~/.local/share/autojump/autojump.txt
}

function qrInit(){
    pkgCheckInstall qrencode
    pkgCheckInstall qrencode-devel
    pkgCheckInstall qrencode-libs
    pkgCheckInstall zbar
}

function main(){
    initWireshark
    initGNU
    miscInit
    qrInit
}

main
