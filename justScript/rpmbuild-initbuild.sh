#!/usr/bin/bash

if [ $PWD != "$HOME/rpmbuild" ];then
    echo "----please run under $HOME/rpmbuid---"
    exit
fi

pkgs="tsocks kernel postfix util-linux coreutils"

for pkg in $pkgs;do
    pkgIns=$(rpm -q $pkg)
    if [ $(echo $pkgIns | grep -c 'not installed') -gt 0 ];then
	echo "----$pkg not installed-----"
	continue
    fi

    srpm="${pkgIns%.x86_64}.src.rpm"
    if [ -f "./$srpm" ];then
	echo "----$srpm had been download--"
    else
	echo "----download srpm for $pkgIns-----"
	dnf download --source $pkgIns
    fi

    spec=$(rpm -ql -p $srpm | grep '\.spec')
    if ! [ -f SPECS/$spec ];then
	rpm -i $srpm
	echo
	echo -e "\033[1;31m----builddep for $pkgIns-----\033[0m"
	echo
	sleep 1
	dnf --assumeyes builddep SPECS/$spec
	echo
	echo -e "\033[1;31m----rpmbuid -bp for $pkgIns-----\033[0m"
	echo
	sleep 1
	rpmbuild -bp SPECS/$spec
    fi


done
