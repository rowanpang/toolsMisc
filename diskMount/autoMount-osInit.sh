#!/bin/bash

source ./osInitframe/lib.sh

function baseInit(){
    local dir=$localdir
    local uRulesDir="/etc/udev/rules.d/"
    local etcSymdDir="/etc/systemd/system/"
    lsudo cp ${dir}diskMount/99-udisk.rules ${uRulesDir}99-udisk.rules
    lsudo cp ${dir}diskMount/auto*.service $etcSymdDir
    lsudo sed -i "s;^ExecStart=.*;ExecStart=${dir}udev_disk_auto_mount.sh %I add;" ${etcSymdDir}autoMount@.service
    lsudo sed -i "s;^ExecStart=.*;ExecStart=${dir}udev_disk_auto_mount.sh %I remove;" ${etcSymdDir}autoUmount@.service

    local selfSymdUdevd="${etcSymdDir}systemd-udevd.service"
    lsudo cp /usr/lib/systemd/system/systemd-udevd.service ${selfSymdUdevd}
    lsudo sed -i 's;^MountFlags;#&;' ${selfSymdUdevd}
}

baseInit
