#/bin/bash
source ./osInitframe/lib.sh
configSelected="${localdir}config-v4.12"

function baseInit(){
    #base
	pkgCheckInstall i3
	pkgCheckInstall i3lock
	pkgCheckInstall i3status
	#pkgCheckInstall i3-doc      #about 124Mib,too big ignore
    #polkit-gnome
	pkgCheckInstall polkit-gnome
    #wallpaper
	pkgCheckInstall feh 
    #xtrlock
	pkgCheckInstall pam-devel
    #config
	ln -snf $dir ${HOMEDIR}.i3
	ln -rsf ${configSelected} ${dir}config 
	lsudo sed -i 's;disk\ /\"$;disk\ /home\";' /etc/i3status.conf
	lsudo sed -i 's;disk\ \"/\";disk\ \"/home\";' /etc/i3status.conf
}

function initI3wm(){
    #config order
        #1. ~/.config/i3/config (or $XDG_CONFIG_HOME/i3/config if set)
        #2. /etc/xdg/i3/config (or $XDG_CONFIG_DIRS/i3/config if set)
        #3. ~/.i3/config
        #4. /etc/i3/config

    local dir=$localdir
    baseInit

    #memSave
	pkgCheckInstall usermode-gtk
	pkgCheckInstall i3lock
	local memSaveDir="${dir}screenlock/memSave/"
	local pamConf="/etc/pam.d/system-auth"
	sed -i "s;PROGRAM=.*;PROGRAM=${memSaveDir}memSave.sh;" ${memSaveDir}memSave.consolehelper
	if [ $(grep -c 'auth\s\+sufficient\s\+pam_unix.so.*nodelay.*' $pamConf) -eq 0 ];then
	    lsudo sed -i 's;auth\s\+sufficient\s\+pam_unix.so.*;& nodelay;' $pamConf                #disable pwd error delay
	fi
	lsudo ln -sf ${memSaveDir}memSave.consolehelper /etc/security/console.apps/memSave
	lsudo ln -sf ${memSaveDir}memsave.pam /etc/pam.d/memsave
	lsudo ln -rsf `which consolehelper` /usr/bin/memSave 

    #---------disable pwd quality check
	local oldUnix="$(sed --quiet '/^password\s\+\S\+\s\+pam_unix.so.*/ p' $pamConf)"
	local newUnix=$(echo "$oldUnix" | sed 's/use_authtok//')
	lsudo sed -i 's/^password\s\+\S\+\s\+pam_pwquality.so.*/#&/' $pamConf
	lsudo sed -i 's/^password\s\+\S\+\s\+pam_cracklib.*/#&/' $pamConf
	if [ "$oldUnix" != "$newUnix" ];then
	    lsudo sed -i 's/^password\s\+\S\+\s\+pam_unix.so.*/#&/' $pamConf
	    lsudo sed -i "/#password\s\+\S\+\s\+pam_unix.so.*/a$newUnix" $pamConf
	fi
    #end---------disable pwd quality check

    #terminal for nautilus
	pkgCheckInstall gnome-terminal-nautilus

    #volume
	pkgCheckInstall volumeicon
	pkgCheckInstall pavucontrol
	#sed -i "/^#volumeicon/ aexec /usr/bin/volumeicon" ${configSelected}

    #nm-applet
	pkgCheckInstall network-manager-applet
	#sed -i "/^#nm-applet/ aexec /usr/bin/nm-applet" ${configSelected}

    #terminator
	#pkgCheckInstall terminator
	#mkdir -p ${HOMEDIR}.config/terminator
	#ln -sf ${dir}dep/terminator/config ${HOMEDIR}.config/terminator/config 

    #xfce4-terminator
	local confDir=${HOMEDIR}.config/xfce4/terminal
	pkgCheckInstall xfce4-terminal-0.6.3
	[ -d $confDir ] || mkdir -p $confDir
	ln -sf ${dir}dep/xfce4-terminal/accels.scm $confDir/accels.scm
	ln -sf ${dir}dep/xfce4-terminal/readme.txt $confDir/readme.txt
	ln -sf ${dir}dep/xfce4-terminal/terminalrc.solarized $confDir/terminalrc

    #synergyX
	local synergyDir="${dir}../synergy/"
	local synerScript=${synergyDir}synergyX.sh
	echo $synerScript
	sed -i "s;^exec \/.*synergyX\.sh$;exec $synerScript;" ${configSelected}
	[ $(grep -c "$synerScript" ${configSelected}) -gt 0 ] || sed -i "/^#synergyX/ aexec $synerScript" ${configSelected}

    #startx
	[ -f $HOME/.Xclients ] || cp ${dir}./Xclients $HOME/.Xclients

    #input-method
	pkgCheckInstall fcitx 
	pkgCheckInstall fcitx-configtool
	pkgCheckInstall sogoupinyin

}

initI3wm
