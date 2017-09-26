#/bin/bash
source ./osInitframe/lib.sh
configSelected="${i3configSelected}"

function baseInit(){
    local dir=$localdir
    #base
	pkgCheckInstall i3
	pkgCheckInstall i3lock
	pkgCheckInstall i3status
	#pkgCheckInstall i3-doc      #about 124Mib,too big ignore
    #polkit-gnome
	pkgCheckInstall polkit-gnome

    #wallpaper
	pkgCheckInstall feh
	ln -snf $dir/wallpaper $HOME/Pictures/wallpaper
	feh --image-bg black --bg-center $HOME/Pictures/wallpaper/dark-person-kristen.png
	sed -i "s;exec .*/\.fehbg;exec $HOME/.fehbg;" $configSelected

	#for memSave usage
	ln -rsf $HOME/Pictures/wallpaper/dark-person-kristen.jpg  \
		$HOME/Pictures/wallpaper/screenlock.png

    #xtrlock
	pkgCheckInstall pam-devel

    #xscreensaver
	#xscreen-daemon to config and preview
	pkgCheckInstall xscreensaver

    #config
	ln -snf $dir ${HOMEDIR}.i3
	ln -rsf ${configSelected} ${dir}config

    #i3status
	local cfgdir="$HOME/.config/i3status"
	local cfgUsed="${dir}i3status.cfg"

	[ -d $cfgdir ] || mkdir $cfgdir
	ln -rsf $cfgUsed $cfgdir/config
}

function memSaveInit(){
    pkgCheckInstall usermode-gtk
    pkgCheckInstall i3lock

    local dir=$localdir
    local memSaveDir="${dir}screenlock/memSave/"
    local pamConf="/etc/pam.d/system-auth"

    sed -i "s;PROGRAM=.*;PROGRAM=${memSaveDir}memSave.sh;" ${memSaveDir}memSave.consolehelper
    if [ $(grep -c 'auth\s\+sufficient\s\+pam_unix.so.*nodelay.*' $pamConf) -eq 0 ];then
	lsudo sed -i 's;auth\s\+sufficient\s\+pam_unix.so.*;& nodelay;' $pamConf                #disable pwd error delay
    fi
    lsudo ln -sf ${memSaveDir}memSave.consolehelper /etc/security/console.apps/memSave
    lsudo ln -sf ${memSaveDir}memsave.pam /etc/pam.d/memsave
    lsudo ln -rsf `which consolehelper` /usr/bin/memSave
}

function pwdQualityCheck(){
    local pamConf="/etc/pam.d/system-auth"

    local oldUnix="$(sed --quiet '/^password\s\+\S\+\s\+pam_unix.so.*/ p' $pamConf)"
    local newUnix=$(echo "$oldUnix" | sed 's/use_authtok//')
    lsudo sed -i 's/^password\s\+\S\+\s\+pam_pwquality.so.*/#&/' $pamConf
    lsudo sed -i 's/^password\s\+\S\+\s\+pam_cracklib.*/#&/' $pamConf
    if [ "$oldUnix" != "$newUnix" ];then
	lsudo sed -i 's/^password\s\+\S\+\s\+pam_unix.so.*/#&/' $pamConf
	lsudo sed -i "/#password\s\+\S\+\s\+pam_unix.so.*/a$newUnix" $pamConf
    fi
}

function terminalInit(){
    local dir=$localdir
    #terminator
	#pkgCheckInstall terminator
	#mkdir -p ${HOMEDIR}.config/terminator
	#ln -sf ${dir}dep/terminator/config ${HOMEDIR}.config/terminator/config
    #xfce4-terminator
	local confDir=${HOMEDIR}.config/xfce4/terminal

	pkgCheckInstall xfce4-terminal
	[ -d $confDir ] || mkdir -p $confDir
	ln -sf ${dir}dep/xfce4-terminal/accels.scm $confDir/accels.scm
	ln -sf ${dir}dep/xfce4-terminal/readme.txt $confDir/readme.txt
	ln -sf ${dir}dep/xfce4-terminal/terminalrc.solarized $confDir/terminalrc
    #terminal for nautilus
	pkgCheckInstall gnome-terminal-nautilus
}

function synergyInit(){
    local dir=$localdir
    local synergyDir="${dir}../synergy/"
    local synerScript=${synergyDir}synergyX.sh
    echo $synerScript
    sed -i "s;^exec \/.*synergyX\.sh$;exec $synerScript;" ${configSelected}
    [ $(grep -c "$synerScript" ${configSelected}) -gt 0 ] || sed -i "/^#synergyX/ aexec $synerScript" ${configSelected}
}

function inputMethoInit() {
    pkgCheckInstall fcitx
    pkgCheckInstall fcitx-configtool
    if ! [ $osVer -eq 26 ];then
	pkgCheckInstall sogoupinyin fzug-free
    fi
}

function initI3wm(){
    #config order
        #1. ~/.config/i3/config (or $XDG_CONFIG_HOME/i3/config if set)
        #2. /etc/xdg/i3/config (or $XDG_CONFIG_DIRS/i3/config if set)
        #3. ~/.i3/config
        #4. /etc/i3/config

    local dir=$localdir
    baseInit
    memSaveInit
    pwdQualityCheck
    terminalInit
    inputMethoInit

    #volume
	pkgCheckInstall volumeicon
	pkgCheckInstall pavucontrol
	#sed -i "/^#volumeicon/ aexec /usr/bin/volumeicon" ${configSelected}
    #nm-applet
	pkgCheckInstall network-manager-applet
	#sed -i "/^#nm-applet/ aexec /usr/bin/nm-applet" ${configSelected}
    #startx
	[ -f $HOME/.Xclients ] || cp ${dir}./Xclients $HOME/.Xclients
}

initI3wm
