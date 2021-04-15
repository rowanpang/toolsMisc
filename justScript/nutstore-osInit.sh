#/bin/bash
source ./osInitframe/lib.sh

function initNutstore(){
    #depend
    pkgCheckInstall java-*-openjdk
    if [ $osVendor == "fedora" -a $osVer -lt 31 ];then
	    pkgCheckInstall notify-python
    fi

    #$rpm -qi nautilus-nutstore
	#Name        : nautilus-nutstore
	#Version     : 3.1.0
	#Release     : 1.fc19
	#Architecture: x86_64

    nutdsk="$HOME/.nutstore/dist/gnome-config/menu/nutstore-menu.desktop"

    if ! [ -f $nutdsk ];then
        pr_info "installing nutstore"
	if [ $osVendor == "fedora" -a $osVer -eq 31 ];then
	    nutroot=$HOME/.nutstore;nutsrc=$nutroot/src;mkdir -p $nutsrc
	    yum install glib2-devel gtk2-devel nautilus-devel gvfs libappindicator-gtk3  python2-gobject
	    wget https://www.jianguoyun.com/static/exe/installer/nutstore_linux_src_installer.tar.gz -O $nutsrc/nutstore_linux_src_installer.tar.gz
	    opwd=$PWD
	    cd $nutsrc && tar zxf nutstore_linux_src_installer.tar.gz && cd ./nutstore_linux_src_installer
	    ./configure && make && make install && nautius -q && ./runtime_bootstrap
	    cd $opwd
	else
            lsudo yum install  https://www.jianguoyun.com/static/exe/installer/fedora/nautilus_nutstore_amd64.rpm
	fi

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
    sed -i "s;exec .*/\(\.nutstore/dist/bin/nutstore-pydaemon.py\);exec \$HOME/\1;" $i3cfg
}

initNutstore
