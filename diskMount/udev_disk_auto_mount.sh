#!/bin/sh
LOG=/tmp/log-udev_disk_auto_mount.log
#LOG=/dev/null
function verbose(){
	echo "$@" >> $LOG
}

mntDir=""
timeStamp=`/bin/date +%Y%m%d%H%M%S`
uidPangwz=`id --user pangwz`

verbose $0
verbose "action:$ACTION"
verbose "dev:${DEVNAME}"

function add(){
	local mntOpt=""
	mntDir="/media/${ID_FS_LABEL}"
	if [ -e $mntDir ];then
		mntDir="/media/${ID_FS_LABEL}-$timeStamp"
	fi
	verbose "mnt dir:$mntDir"

	mkdir $mntDir;
	if [ "${ID_FS_TYPE}" == "vfat" ];then
		mntOpt="-o uid=$uidPangwz,gid=$uidPangwz,utf8,fmask=0113"
	fi

	verbose "mntopt:$mntOpt"
	/bin/mount $mntOpt ${DEVNAME} $mntDir
	verbose "after add"
}

function remove(){
	verbose "in remove"
	mntDir=`/bin/mount | /bin/grep ${DEVNAME} | awk '{print $3}'`
	verbose "mnted dir:$mntDir"

	/bin/umount $mntDir
	rm -r $mntDir
	verbose "after remove"
}

if [ "$ACTION" == "add" ];then
	add
elif [ "$ACTION" == "remove" ];then
	remove
fi
