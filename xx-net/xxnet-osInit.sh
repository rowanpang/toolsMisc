#!/bin/bash

source ./osInitframe/lib.sh

function initXXnet(){
    local dir=$localdir
    pkgCheckInstall pyOpenSSL

    lsudo cp ${dir}code/default/xx_net.sh /etc/init.d/xx_net
    lsudo sed -i "/^PACKAGE_VER_FILE=/ iPACKAGE_PATH=\"${dir}code/\"" /etc/init.d/xx_net
    lsudo chkconfig --add xx_net
}

initXXnet
