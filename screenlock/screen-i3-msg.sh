#!/bin/bash 

i3-msg 'workspace 10;exec gnome-terminal --profile=ptest --full-screen -e "/home/pangwz/cmatrix/cmatrix -B";exec /home/pangwz/xtrlock/xtrlock-pam/install/bin/xtrlock-pam -p system-auth -b none 2>/home/pangwz/err.log'
