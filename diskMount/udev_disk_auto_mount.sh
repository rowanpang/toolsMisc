#!/bin/sh
function verbose(){
    echo "$@" >> $LOG
}

function add(){
    local mntOpt=""
    local mntDir="/media/${ID_FS_LABEL}.${ID_FS_TYPE}"
    #if [ -e $mntDir ];then
        #mntDir="${mntDir}-$timeStamp"
    #fi
    verbose "mnt dir:$mntDir"

    mkdir $mntDir;
    if [ "${ID_FS_TYPE}" == "vfat" ];then
        mntOpt="-o uid=$uidPangwz,gid=$uidPangwz,utf8,fmask=0113"
    fi

    if [ "${ID_FS_TYPE}" == "ntfs" ];then
        mntOpt="-t ntfs-3g -o uid=$uidPangwz,gid=$uidPangwz,utf8,fmask=0113,dmask=0022"
    fi    

    verbose "mntopt:$mntOpt"
    /bin/mount $mntOpt ${DEVNAME} $mntDir
    verbose "after add"
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
#LOG=/dev/null

timeStamp=`/bin/date +%Y%m%d%H%M%S`
uidPangwz=`id --user pangwz`

[ $1 ] && DEVNAME="/dev/${1}"
[ $2 ] && ACTION=$2

verbose $0
verbose "action:$ACTION"
verbose "dev:${DEVNAME}"

eval $(blkid -po udev ${DEVNAME})
[ -z ${ID_FS_LABEL} ] && ID_FS_LABEL=uDisk

if [ "$ACTION" == "add" ];then
    add
elif [ "$ACTION" == "remove" ];then
    remove
fi
