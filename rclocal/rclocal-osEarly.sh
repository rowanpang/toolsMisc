#!/bin/bash
# dict generator

source ./osInitframe/lib.sh

function baseInit(){
    local dir=$localdir
    rcT='/etc/rc.d/rc.local'
    rcl=`mktemp --dry-run -t rclocal-XXXXXXXX`
    rcdir="${dir}doit/"

    cat > $rcl << EOF
#!/usr/bin/bash

#-----auto genby $0------
for script in \`ls ${rcdir}\`;do
    f="${rcdir}\$script"
    if [ -x \$f ];then
	echo "---rc.local do script \$f-----"
	\$f
    fi
done
EOF

    lsudo cp -f $rcl $rcT
    lsudo chmod a+x $rcT
}

baseInit
