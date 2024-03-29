#!/bin/sh

function dirGit(){
	local cmd=$1
	local dir=$2
	local file=$3

	if [ -d $dir/.git ];then
		echo "--------------git for $dir---------------------"
		git -C $dir $cmd ${file#*\/}
		#if [ $file ];then	
			#git -C $dir $cmd ${file}
		#else
			#git -C $dir $cmd 
		#fi
	fi
}

function perDirGit(){
	local cmd=$1
	for dir in `ls`;do
		if [ -d $dir/.git ];then
			echo "--------------git for $dir---------------------"
			git -C $dir $cmd
		fi
	done
}

#main
[ $# -gt 0 ] || { echo "Usage: $0 gitcmd [dir] [files]" && exit -1; }
[ $1 ] && cmd=$1 && shift
[ $1 ] && targetDir=$1 && shift
[ $1 ] && targetFile=$1 && shift

echo "$0 workdir:$PWD"
echo -e "\tcmd is:$cmd $targetDir $targetFile"
if [ $targetDir ];then
	dirGit $cmd $targetDir $targetFile
else
	perDirGit $cmd
fi
