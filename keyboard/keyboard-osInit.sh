#/bin/bash
source ./osInitframe/lib.sh

xorgKeyboardConf=/etc/X11/xorg.conf.d/00-keyboard.conf
function ctrlCapsSwapX11(){
    #swapcaps,ctrl
    pkgCheckInstall xorg-x11-xkb-utils
    #setxkbmap -option ctrl:swapcaps
    if [ -f $xorgKeyboardConf ];then
        local count=`grep -c 'ctrl:swapcaps' $xorgKeyboardConf`
        if [ $count -eq 0 ];then 
            pr_info "modify $xorgKeyboardConf"
            lsudo sed -i '/EndSection/ i \\tOption "XKbOptions" "ctrl:swapcaps"' $xorgKeyboardConf
        else
            pr_info "$xorgKeyboardConf had configured"
        fi
    else
        pr_warn "$xorgKeyboardConf not exist"        
    fi  
}   

function ctrlCapsSwapKern(){
    rclocal="/etc/rc.d/rc.local"
    dir="$localdir"
    rcdir="${dir}../rclocal/doit/"
    maps=${dir}kernCtrlCap.maps
    script=${rcdir}keyboard-rcInit.sh


    if [ -e $rclocal ] && [ -d $rcdir ];then
	cat > $script <<EOF
#!/bin/bash

#---genby keyboard when keyboard do init--- 
#---$0---
loadkeys $maps
EOF
	chmod a+x $script
    fi
}

ctrlCapsSwapX11
ctrlCapsSwapKern
