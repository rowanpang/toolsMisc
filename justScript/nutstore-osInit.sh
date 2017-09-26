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

    local i3cfg="$i3configSelected"
    sed -i "s;exec .*/\(\.nutstore/dist/bin/nutstore-pydaemon.py\);exec $HOME/\1;" $i3cfg
}

initNutstore
