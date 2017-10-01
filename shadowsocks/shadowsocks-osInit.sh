#!/bin/bash
source ./osInitframe//lib.sh
function ssInit(){
    dir=$localdir

    #pkgCheckInstall python-shadowsocks
    pkgCheckUninstall python-shadowsocks
    pkgCheckInstall libsodium  	updates

    if ! [ -f /etc/yum.repos.d/_copr_librehat-shadowsocks.repo ];then
	lsudo dnf copr enable librehat/shadowsocks
	lsudo dnf copr disable librehat/shadowsocks
    fi
    pkgCheckInstall shadowsocks-libev.x86_64 librehat-shadowsocks

    method='systemd'
    cronSvr='/etc/cron.d/shadowSocks-update'
    local    svr=shadowsocks-rowan.service
    local chksvr=shadowsocks-rowan-chk.service
    local chktmr=shadowsocks-rowan-chk.timer

    local    ssvrcfg="${dir}systemd-${svr}"
    local schksvrcfg="${dir}systemd-${chksvr}"
    local schktmrcfg="${dir}systemd-${chktmr}"

    local    dsvrcfg="/etc/systemd/system/${svr}"
    local dchksvrcfg="/etc/systemd/system/${chksvr}"
    local dchktmrcfg="/etc/systemd/system/${chktmr}"

    local svrExec="${dir}ssRun.sh"
    local chkExec="${dir}ssChk.sh"
    local chkArg="--checkTime --systemd"

    if [ $method == 'systemd' ];then
	[ -f $cronSvr ] && lsudo rm -f $cronSvr

	lsudo cp    $ssvrcfg $dsvrcfg
	lsudo cp $schksvrcfg $dchksvrcfg
	lsudo cp $schktmrcfg $dchktmrcfg

	lsudo sed -i "s;\(^ExecStart=\)\S\+$;\1${svrExec};" $dsvrcfg
	lsudo sed -i "s;\(^ExecStart=\)\S\+$;\1${chkExec} ${chkArg};" $dchksvrcfg
	[ $? ] && systemctl enable $chktmr

    else
	#journal --identifier CORND   to check log
	systemctl disable $chktmr
	lsudo sh -c "cat << EOF > /etc/cron.d/shadowSocks-update
3-59/3 * * * * $USER ${dir}ssStart.sh --checkTime
EOF"
    fi
}

function pScriptInit(){
    tdir="${localdir}../shell/bin/"

    scripts="phome.sh lvzl.sh"

    for f in $scripts;do
	pscript=${localdir}$f
	if ! [ -f $pscript ];then
	    echo 'hello' > $pscript
	fi
	ln -sf $pscript $tdir
    done
}

function pacInit(){
    lcfg="${localdir}proxy.pac"
    lsudo ln -sf ${lcfg} /var/www/html/rowan.pac
    nProxy="'SOCKS ${dip}:1080'"
    sed -i "s#\(var autoproxy = \).*;#\1$nProxy;#" $lcfg

    svrNames="http https"	    #http,https for proxy.pac
    for svr in $svrNames;do
	lsudo firewall-cmd --add-service=$svr		    #take effect immediately
	lsudo firewall-cmd --permanent --add-service=$svr   #only after service restart or reload
    done
}

function firewalldAddService(){
    svrName=$1

    svrcfgl="${localdir}firewalld-${svrName}.xml"
    svrcfgt="/etc/firewalld/services/${svrName}.xml"
    lsudo cp $svrcfgl $svrcfgt
    lsudo systemctl start firewalld.service
    lsudo firewall-cmd --add-service=$svrName		    #take effect immediately
    lsudo firewall-cmd --permanent --add-service=$svrName    #only after service restart or reload
}

function firewalldInit(){
    if ! [ -x "/usr/sbin/firewalld" ];then
	pr_warn "not firewalld system"
    fi

    firewalldAddService "socksRowan"
}

function main(){
    pacInit
    pScriptInit
    ssInit
    firewalldInit
}

main
