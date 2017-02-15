#/bin/bash

port=8000
prog=$0
both=true

[ -L $prog ] && tDir=`dirname $(readlink $prog)`/

while [ $# -gt 0 ];do
    case "$1" in
	p)
	    put=true
	    both=false
	    echo "--------download files--------"
	    python -m SimpleHTTPServer $port
	    ;;
	g)
	    get=true
	    both=false
	    echo "--------upload files--------"
	    python ${tDir}upload.py
	    ;;
	pg)
	    both=true
	    ;;
    esac
    shift
done

if [ $both == "true" ];then
    echo "--------upload/download files--------"
    python ${tDir}SimpleHTTPServerWithUpload.py
fi
