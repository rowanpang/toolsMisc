#!/bin/sh
program=$0

function Usage(){
    echo "need param"
    echo "Usage: $program 'old.iso'"
}

[ $UID -eq 0 ] || { echo "need root privilage" && exit -1; }

#check param
if [ $# -lt 1 ];then
    Usage
    exit -1;
fi    

BASEDIR=/home/pangwz/vm-iso/
WORKDIR=${BASEDIR}make/
verControl=0

oldIsoPrefix=${1%.*}
oldIso=${oldIsoPrefix}.iso
newIsoPrefix=new-${oldIsoPrefix}
newIso=${newIsoPrefix}.iso

PREFIX=${WORKDIR}${oldIsoPrefix}
LOGFILE=${WORKDIR}${oldIsoPrefix}-log

function prepareNewIsoMntDir(){
    local tmpMnt=${PREFIX}-mntNew/
    [ -d ${tmpMnt} ] || mkdir -p ${tmpMnt}        
}

function prepareOldIso(){
    oldDir=${PREFIX}-old/
    [ -d ${oldDir} ] || mkdir -p ${oldDir}
    mount -o loop $oldIso ${oldDir}
    echo $oldDir
}

function prepareUpper(){
    local upperDirTMP=${PREFIX}-upper
    if [ $verControl -eq 1 ];then
        local curVer=1
        local newVer=1
        for f in ${upperTMP}*;do
            if [ -d $f ];then
                let curVer+=1
            fi
        done

        local curUpperDir=${upperDirTMP}V${curVer}-`date +%Y%m%d-%H%M%S`/
        local newUpperDir=${upperDirTMP}V${newVer}-`date +%Y%m%d-%H%M%S`/
    
        if [ $curVer -eq 1 ];then
            mkdir -p ${newUpperDir}
        else
            let newVer=$curVer+1
            rm -rf ${curUpperDir}${newIso}
            cp -r ${curUpperDir} ${newUpperDir}                    
        fi
    else
        local newUpperDir=${upperDirTMP}/
        [ -d ${newUpperDir} ] || mkdir -p ${newUpperDir}        
    fi        
    echo ${newUpperDir}
}    

function overlayfs(){
    local upper
    local old
    local work=${PREFIX}-work/
    local new=${PREFIX}-new/
    upper=$(prepareUpper)
    old=$(prepareOldIso)
    [ -d ${work} ] || mkdir -p ${work}
    [ -d ${new} ] || mkdir -p ${new}

    mount -t overlay ovl-${oldIsoPrefix} -olowerdir=${old},upperdir=${upper},workdir=${work} ${new}

    echo "${new} ${old} ${upper}"
}

#$1:for new dir
function subShell(){
    echo "call & enter new bash"
    local scriptName=newIso.sh
    local xmlName=xmlnew.xml
    local vendor="RowanPang"
    local isoid="${oldIsoPrefix}-`date +%F`"
    cd ${1}
    local labelName=$(echo -e `awk '/.*hd:LABEL=.*/ {print $3;exit}' isolinux/isolinux.cfg | awk 'BEGIN{FS="="} {print $3}'`)
    #if ! [ -f ${scriptName} ];then
cat << EOF >${scriptName}
#auto gen by isoMK.sh
#!/bin/sh

[ -f $xmlName ] || { echo "need prepare $xmlName" && exit -1; }
[ -f $newIso ] && rm -f $newIso
[ -d repodata ] && rm -rf repodata

echo "-------------createrepo----------" | tee --append $LOGFILE
#need verbose -v 
createrepo -v -g $xmlName --workers 10  .  | tee --append $LOGFILE

echo "-----mkisofs------" | tee --append $LOGFILE
sleep 0.5
#need quiet? -quiet
mkisofs									    \\
	-b isolinux/isolinux.bin	    				    \\
	-c isolinux/boot.cat	    	    				    \\
	-no-emul-boot		    	    				    \\
	-boot-load-size 4	    	    				    \\
	-boot-info-table	    	    				    \\
	-R			    	    				    \\
	-eltorito-alt-boot	    	    				    \\
	-efi-boot images/efiboot.img	    				    \\
	-no-emul-boot		    	    				    \\
	-J			    	    				    \\
	-V '${labelName}'	    	    				    \\
	-publisher '${vendor}'		    				    \\
	-appid '${isoid}'		    				    \\
	-m '$scriptName'	    	    				    \\
	-m '$xmlName'		    	    				    \\
	-m "lost+found"			    				    \\
	-o ${newIso} .		    	    				    \\
	| tee --append $LOGFILE
EOF
    #fi
    chmod a+x ${scriptName}
    cp ./repodata/repomd.xml $xmlName
    /bin/bash
    cd -
}

#$1:new dir
#$2:old dir
#$3:upper dir
function unPrepare(){
    umount ${1}
    umount ${2}    

    cd ${3}
}
        
function main(){
    local ovl
    prepareNewIsoMntDir
    ovl=$(overlayfs)
    echo "call & enter new bash" > $LOGFILE
    [ $? ] || exit -1
    subShell $ovl
    echo "after bash" >> $LOGFILE
    unPrepare $ovl
    echo "exit $program"
    echo "exit $program">> $LOGFILE
}    

main
