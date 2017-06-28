#/bin/bash

port=8000
prog=$0
both=true

function usage(){
    echo "
	-h: for this help mesg	
	 p: put file,share files for download
	 g: get file,allow upload files
	pg: put and get 
	-p: port  default is $port  just useful with p/g/pg
	"
    exit
}

[ -L $prog ] && tDir=`dirname $(readlink $prog)`/

while [ $# -gt 0 ];do
    case "$1" in
	-h)
	    usage
	    ;;
	-p)
	    port=$2
	    shift
	    ;;
	p)
	    put=true
	    both=false
	    ;;
	g)
	    get=true
	    both=false
	    ;;
	pg)
	    both=true
	    ;;
    esac
    shift
done

if [ "$put" ];then
    echo "--------download files--------"
    python -m SimpleHTTPServer $port
elif [ "$get" ];then
    echo "--------upload files--------"
    python ${tDir}upload.py
elif [ "$both" == "true" ];then
    echo "--------upload/download files--------"
    python ${tDir}SimpleHTTPServerWithUpload.py
fi
