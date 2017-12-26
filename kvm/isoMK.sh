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

BASEDIR="$PWD/"
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

function prepareGroupxml(){
    newXmlName="groupNewXml.xml"
    orgXml=$(python << "_EOF"
import xml.etree.ElementTree as ET
import hashlib
import binascii
import sys

tree = ET.parse('./repodata/repomd.xml')
root = tree.getroot()
grp = root.find('./{http://linux.duke.edu/metadata/repo}data[@type="group"]')
for c in grp.getchildren():
    if c.tag.endswith('location'):
	fPath = c.attrib['href']
	# print fPath
    if c.tag.endswith("checksum"):
	hashT = c.attrib["type"]
	hashV = c.text
	# print hashT
	# print hashV

hobj = hashlib.new(hashT)
hobj.update(open(fPath).read())

hashCal = binascii.hexlify(hobj.digest())

if hashV == hashCal:
    #os.system('cp %s groupXml.xml' %(fPath))
    print fPath
else:
    print 'org groupxml fail'
    sys.exit(-1)
_EOF
)
    ret=$?
    if [ $ret -eq 0 ];then
	cp $orgXml $newXmlName
	echo $newXmlName
    fi
    return $ret
}

#$1:for new dir
function subShell(){
    cd ${1}
    echo "call & enter new bash"
    local scriptName="mkNewIso.sh"
    local newGroupXml=$(prepareGroupxml)

cat << EOF >${scriptName}
#auto generate by isoMK.sh
#!/bin/sh

vendor="RowanPang"
isoid="${oldIsoPrefix}-`date +%F`"
loaderType="unknown"

function envChkPrepare() {
    if [ -d isolinux ];then
	loaderType="isolinux"
    elif [ -d boot/grub ] && [ -s ppc/bootinfo.txt ];then
	loaderType="grubPowerPc"
    else
	echo 'unknown bootloader,exit -1'
	exit -1
    fi

    [ -f "$newGroupXml" ] || { echo "need prepare $newGroupXml" && exit -1; }
    [ -f $newIso ] && rm -f $newIso
}

function repoDateUpdate(){
    echo "createrepo----------" | tee --append $LOGFILE
    [ -d repodata ] && rm -rf repodata
    createrepo -v -g $newGroupXml --workers 10  .  | tee --append $LOGFILE
}

function isofsIsolinux(){
    echo "loader isolinux"
    local labelName="\$(echo -e \`awk '/.*hd:LABEL=.*/ {print \$3;exit}'    \\
			isolinux/isolinux.cfg | awk 'BEGIN{FS="="} {print   \\
			\$3}'\`)"

    mkisofs								    \\
	    -b isolinux/isolinux.bin	    				    \\
	    -c isolinux/boot.cat					    \\
	    -no-emul-boot						    \\
	    -boot-load-size 4	    	    				    \\
	    -boot-info-table	    	    				    \\
	    -R			    	    				    \\
	    -eltorito-alt-boot	    	    				    \\
	    -efi-boot images/efiboot.img				    \\
	    -no-emul-boot						    \\
	    -J			    	    				    \\
	    -V \${labelName}	    	    				    \\
	    -publisher \${vendor}					    \\
	    -appid \${isoid}		    				    \\
	    -m $scriptName	    	    				    \\
	    -m $newGroupXml							    \\
	    -m "lost+found"						    \\
	    -o ${newIso} .						    \\
	    | tee --append $LOGFILE

}

function sectionKeyVal(){
    local section="\$1" key="\$2" cursec="" k="" v=""
    while read line; do
        case "\$line" in
            \#*) continue ;;
            \[*\]*) cursec="\${line#[}"; cursec="\${cursec%%]*}" ;;
            *=*) k=\$(echo \${line%%=*}); v=\$(echo \${line#*=}) ;;
        esac
        if [ "\$cursec" = "\$section" ] && [ "\$k" == "\$key" ]; then
            echo \$v
            break
        fi
    done
}

function isoGrubPowerPc(){
    echo "loader Grub"
    local labelName="RHEL-LE-7.1 Server.ppc64le"
    local NV="\$(sectionKeyVal product short < .treeinfo)-\$(sectionKeyVal product version < .treeinfo)"
    local VA="\$(sectionKeyVal tree variants < .treeinfo).\$(sectionKeyVal tree arch < .treeinfo)"
    local labelName="\$NV \$VA"

    mkisofs				\\
	    -U				\\
	    -chrp-boot			\\
	    -R				\\
	    -J				\\
	    -V "\${labelName}"		\\
	    -sysid "ppc"		\\
	    -graft-points		\\
	    -m $scriptName		\\
	    -m $newGroupXml			\\
	    -m "lost+found"		\\
	    -publisher \${vendor}	\\
	    -o ${newIso} .		\\
	    | tee --append $LOGFILE
}

function isoMake() {
    echo "mkisofs, loader \$loaderType" | tee --append $LOGFILE
    sleep 1.5
    case \$loaderType in
	"isolinux")
	    isofsIsolinux
	    ;;
	"grubPowerPc")
	    isoGrubPowerPc
	    ;;
	*)
	    echo 'unknown loaderType'
	    ;;
    esac
}

function main(){
    envChkPrepare
    repoDateUpdate
    isoMake
}

main

EOF
    chmod a+x ${scriptName}
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
