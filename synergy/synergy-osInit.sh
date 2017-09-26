#!/bin/bash

source ./osInitframe/lib.sh

#just init configfile, start ./synergyX.sh by i3
function initSynergy(){
    local dir=$localdir
    local conf='ll'		#linux on left
    local conf='lu'		#linux on up
    local conf='lr'		#linux on right 
    tconf="$HOME/.synergy.conf"

    case $conf in
	'll')
	    lsudo ln -sf ${dir}synergy.conf.llwr  /etc/synergy.conf
	    ln -sf ${dir}synergy.conf.llwr  $tconf
	    ;;
	'lr')
	    lsudo ln -sf ${dir}synergy.conf.lrwl  /etc/synergy.conf
	    ln -sf ${dir}synergy.conf.lrwl $tconf
	    ;;
	'lu')
	    lsudo ln -sf ${dir}synergy.conf.luwd  /etc/synergy.conf
	    ln -sf ${dir}synergy.conf.luwd $tconf
	    ;;
	*)
	    return -1
	    ;;
    esac
}

initSynergy
