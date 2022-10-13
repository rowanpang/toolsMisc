#!/bin/bash
#rsync will log to /var/log/reposync/x.log
#log are rotated by logrotate, ref /etc/logrotate.d/*

if [ $# -lt 1 ];then
    exit
fi
echo "Staring rsync.....`date +'%Y%m%d-%H%m%S'`........"
logdir="/var/log/reposync/"
[[ -d $logdir ]] || mkdir -p $logdir

#centos7 x86_64
id=centos
dir="/var/www/html/repo/centos/7"
[[ -d $dir ]] || mkdir -p $dir

logf=$logdir/$id.`date +'%Y%m%d-%H%m%S'`.log
logf=$logdir/$id.log
rsync -avHSP --delete --include 'os**' --include 'updates**' --include 'isos**' --exclude '*' rsync://mirrors.tuna.tsinghua.edu.cn/centos/7/ $dir >$logf 2>&1 &

#epel for centos7 x86_64
id=epel
dir="/var/www/html/repo/epel/7/x86_64"
[[ -d $dir ]] || mkdir -p $dir

logf=$logdir/$id.`date +'%Y%m%d-%H%m%S'`.log
logf=$logdir/$id.log
rsync -avHSP --delete --include 'Package**' --include 'repodata**' --exclude '*' rsync://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/ $dir >$logf 2>&1 &

#mysql for el7 x86_64
id=mysql
dir="/var/www/html/repo/mysql/"
[[ -d $dir ]] || mkdir -p $dir

logf=$logdir/$id.`date +'%Y%m%d-%H%m%S'`.log
logf=$logdir/$id.log
rsync -avHSP --delete --include '*-el7-x86_64**' --exclude '*' rsync://mirrors.tuna.tsinghua.edu.cn/mysql/yum/ $dir >$logf 2>&1 &

gpgkey="$dir/RPM-GPG-KEY-mysql"
[[ -f $gpgkey ]] || curl https://repo.mysql.com/RPM-GPG-KEY-mysql > $gpgkey 2>/dev/null &
