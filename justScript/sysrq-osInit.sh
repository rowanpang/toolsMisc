
#/bin/bash
source ./osInitframe/lib.sh

function enableAllsysRq(){
    lsudo sh -c "echo '1' > /proc/sys/kernel/sysrq"
    lsudo sh -c "echo 'kernel.sysrq = 1' > /etc/sysctl.d/sysrq-Rowan.conf"
}   

enableAllsysRq
