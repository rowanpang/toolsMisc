#/bin/bash
source ./osInitframe/lib.sh

function initGraphviz(){
    fedoraRepo="True"
    if [ $fedoraRepo == "True" ];then
	pkgsInstall graphviz graphviz-python graphviz-devel
    else
	repofile="/etc/yum.repos.d/graphviz-fedora.repo"
	if ! [ -f $repofile ];then
	    lsudo wget --output-document $repofile  \
			http://www.graphviz.org/graphviz-fedora.repo
	fi
	lsudo sed -i 's/^enabled=1/enabled=0/' $repofile
	pkgCheckInstall graphviz-qt.x86_64 graphviz-snapshot
	pkgsInstall graphviz graphviz-doc graphviz-graphs
    fi

    sudo dot -c					    #gen configure
    cp ${localdir}k柯南.jpg $HOME/Pictures
}

function initGnuplot(){
    pkgsInstall gnuplot
    pkgsInstall gnuplot-doc
}

function initDia(){
    pkgsInstall dia
}

function initQr(){
    pkgCheckInstall qrencode
    pkgCheckInstall qrencode-devel
    pkgCheckInstall qrencode-libs
    pkgCheckInstall zbar
    pyVer=`python -V | awk '{print $2}' | awk -F "." '{print $1}'`
    if [ $pyVer -eq 3 ]; then
        pkgCheckInstall python3-qrcode
    else
	pkgCheckInstall python-qrcode
    fi
}

function initMisc(){
    #gui version of xrandr
    pkgCheckInstall arandr

    #launches a given program when X session has been idle for a given time
    pkgCheckInstall xautolock
}

initGraphviz
initDia
initQr
initGnuplot
initMisc
