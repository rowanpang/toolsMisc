#/bin/bash

port=8000
prog=$0

while [ $# -gt 0 ];do
    case "$1" in
	s)
	    strict=true
	    ;;
	g)
	    get=true
	    ;;
	sg)
	    strict=true
	    get=true
	    ;;
    esac
    shift
done

[ -L $prog ] && tDir=`dirname $(readlink $prog)`/

if [ $strict ];then
    if [ $get ];then
	echo "--------upload files--------"
	python ${tDir}upload.py
    else
	echo "--------download files--------"
	python -m SimpleHTTPServer $port
    fi
else
    echo "--------upload/download files--------"
    python ${tDir}SimpleHTTPServerWithUpload.py
fi
