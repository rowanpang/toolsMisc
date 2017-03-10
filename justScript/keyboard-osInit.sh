#/bin/bash
source ./osInitframe/lib.sh

xorgKeyboardConf=/etc/X11/xorg.conf.d/00-keyboard.conf
function initKeyBoard(){
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

initKeyBoard
