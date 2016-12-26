KERNEL=="sd[b-z][1-9]", SUBSYSTEM=="block", RUN+="/home/pangwz/tools/toolsMisc/diskMount/udev_disk_auto_mount.sh %k"
