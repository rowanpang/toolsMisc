#/bin/bash
source ./osInitframe/lib.sh

function initNutstore(){
    #depend
    pkgCheckInstall java-*-openjdk
    pkgCheckInstall notify-python

    #$rpm -qi nautilus-nutstore
	#Name        : nautilus-nutstore
	#Version     : 3.1.0
	#Release     : 1.fc19
	#Architecture: x86_64

    if ! [ "$(pkgInstalled nautilus-nutstore)" ];then
        pr_info "installing nutstore"
        lsudo rpm -i https://www.jianguoyun.com/static/exe/installer/fedora/nautilus_nutstore_amd64.rpm
    else
	pr_info "nutstore installed"
    fi

    for tdir in /home/*;do
	THISUSER=`echo $I | cut -d "/" -f 3 -`
	USERID=`id -u $THISUSER 2>/dev/null || echo "_FALSE_"`
	if [ $USERID = '_FALSE_' ] ; then
	    continue
	fi
	break
    done

    local i3cfg="$i3configSelected"
    sed -i "s;exec .*/\(\.nutstore/dist/bin/nutstore-pydaemon.py\);exec $tdir/\1;" $i3cfg
}

initNutstore
