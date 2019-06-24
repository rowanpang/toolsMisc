#!/bin/sh
function verbose(){
    fsize=`du -b $LOG | awk '{print $1}'`
    let max=8*1024
    if [ $fsize -gt $max ];then
	echo "------new file-------" > $LOG
    fi

    echo "$@" >> $LOG
}

function add(){
    eval $(blkid -po udev ${DEVNAME} | awk '{print $1}')
    [ -z ${ID_FS_LABEL} ] && ID_FS_LABEL=uDisk

    local mntOpt=""
    local mntDir="/media/${ID_FS_LABEL}.${ID_FS_TYPE}"
    #if [ -e $mntDir ];then
        #mntDir="${mntDir}-$timeStamp"
    #fi
    verbose "mnt dir:$mntDir"

    [ -d $mntDir ] || mkdir $mntDir;
    if [ "${ID_FS_TYPE}" == "vfat" ];then
        mntOpt="-o uid=$uidPangwz,gid=$uidPangwz,utf8,fmask=0113"
    fi

    if [ "${ID_FS_TYPE}" == "ntfs" ];then
        mntOpt="-t ntfs-3g -o uid=$uidPangwz,gid=$uidPangwz,utf8,fmask=0113,dmask=0022"
    fi

    verbose "mntCmd: /bin/mount $mntOpt ${DEVNAME} $mntDir"
    /bin/mount $mntOpt ${DEVNAME} $mntDir
}

function remove(){
    verbose "in remove"
    local mntDir=`/bin/mount | /bin/grep ${DEVNAME} | awk '{print $3}'`
    verbose "mnted dir:$mntDir"

    /bin/umount $mntDir
    rm -r $mntDir

    verbose "after remove"
}

LOG=/tmp/log-udev_disk_auto_mount.log
touch $LOG
#LOG=/dev/null

timeStamp=`/bin/date +%Y%m%d%H%M%S`
uidPangwz=`id --user pangwz`

[ $1 ] && DEVNAME="/dev/${1}"
[ $2 ] && ACTION=$2

verbose "----start:$0"
verbose "action:$ACTION"
verbose "dev:${DEVNAME}"

if [ "$ACTION" == "add" ];then
    add
elif [ "$ACTION" == "remove" ];then
    remove
fi
verbose "----end:$0"
verbose ""
