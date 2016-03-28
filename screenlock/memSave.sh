#!/bin/bash 

i3-msg 'workspace 10;exec gnome-terminal --profile=ptest --full-screen -e "cmatrix -B";exec xtrlock-pam -p system-auth -b none' > /dev/null
echo 'mem' > /sys/power/state
