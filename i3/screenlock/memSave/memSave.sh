#!/bin/bash
TOOLSDIR="/home/pangwz/tools/i3wm/screenlock/"
LOGFILE="/tmp/memSave-log.txt"

function verbose(){
    if [ " " ];then
	echo "$@" >> $LOGFILE
    fi
}

function verboseInit(){
    verbose
    verbose
}

function now(){
    echo `date +%Y%m%d-%H%M%S`
}

function do_work(){
    verbose "----------------in $FUNCNAME---$(now)------------"
    local CMATRIX=${TOOLSDIR}cmatrix/cmatrix-1.2a/cmatrix
    local XTRLOCK=${TOOLSDIR}xtrlock/xtrlock-pam
    #i3-msg "workspace 10;exec gnome-terminal --full-screen --command \"$CMATRIX -B\";exec $XTRLOCK -p system-auth -b none" > /dev/null
    #i3-msg "workspace 10;exec /home/pangwz/tools/i3wm/screenlock/xtrlock/xtrlock-pam -p system-auth -b none" > /dev/null
    verbose "--euid:$EUID-------"
    #if [ $EUID -eq 0 ];then
	    #passwd >/dev/null 2>&1 << EOF
#QQ@476581728
#QQ@476581728
#EOF
	    #[ -f $LOGFILE ] && chmod 666 $LOGFILE
    #else
	    #passwd >/dev/null 2>&1 << EOF

#QQ@476581728
#QQ@476581728
#EOF
    #fi

    verbose "--i3lock--"
    i3lock -i $HOME/Pictures/wallpaper/screenlock.png
    echo 'mem' > /sys/power/state
#--------------------------power down--------------------------------#
    verbose "--after mem power--$(now)"
    while [ "`pidof i3lock`" ];do
	verbose "--sleep--"
	sleep 1
    done
    verbose "--after sleep--$(now)"

    #if [ $EUID -eq 0 ];then
	#passwd >/dev/null 2>&1 << EOF


#EOF
    #else
	#passwd &>/dev/null << EOF
#QQ@476581728


#EOF
    #fi
    verbose "-----------------out $FUNCNAME--$(now)------------"
}

#---Main
verboseInit
do_work
