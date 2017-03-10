#/bin/bash
source ./osInitframe/lib.sh

function initNutstore(){
    #depend
    pkgCheckInstall java-*-openjdk
    pkgCheckInstall notify-python

    if ! [ "$(pkgInstalled nautilus-nutstore)" ];then
        pr_info "installing nutstore"
        lsudo rpm -i https://www.jianguoyun.com/static/exe/installer/fedora/nautilus_nutstore_amd64.rpm
    else
	pr_info "nutstore installed"
    fi
}

initNutstore