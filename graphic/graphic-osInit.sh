#/bin/bash
source ./osInitframe/lib.sh

function initGraphviz(){
    repofile="/etc/yum.repos.d/graphviz-fedora.repo"
    if ! [ -f $repofile ];then
	lsudo wget --output-document $repofile  \
		    http://www.graphviz.org/graphviz-fedora.repo 
    fi
    lsudo sed -i 's/^enabled=1/enabled=0/' $repofile
    pkgCheckInstall graphviz-qt.x86_64 graphviz-snapshot
    pkgsInstall graphviz graphviz-doc graphviz-graphs
    sudo dot -c					    #gen configure
}

function initDia(){
    pkgsInstall dia
}

initGraphviz
