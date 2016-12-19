#!/bin/bash 
function do_debug(){
	#echo "----------------in $FUNCNAME---------------"
	env
	i3-msg -v
	sleep 130
}

TOOLSDIR="/home/$USER/tools/i3wm/screenlock/"
CMATRIX=${TOOLSDIR}cmatrix/cmatrix-1.2a/cmatrix
XTRLOCK=${TOOLSDIR}xtrlock/xtrlock-pam


function do_work(){
	#echo "----------------in $FUNCNAME---------------"
	#i3-msg "workspace 10;exec gnome-terminal --full-screen --command \"$CMATRIX -B\";exec $XTRLOCK -p system-auth -b none" > /dev/null
	#i3-msg "workspace 10;exec /home/pangwz/tools/i3wm/screenlock/xtrlock/xtrlock-pam -p system-auth -b none" > /dev/null
	i3lock -i /home/pangwz/Pictures/wallpaper/sky.png
	echo 'mem' > /sys/power/state
}

#---Main
debug=0
if [ $debug -eq 1 ];then
	do_debug
else
	do_work
fi
