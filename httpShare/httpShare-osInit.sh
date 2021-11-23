#!/bin/bash

source ./osInitframe/lib.sh

function phpFileShare(){
    phpDir="/var/www/html/filemanager"
    php="$phpDir/filemanager.php"

    user=kuxInspur
    mypwd=kuxInspur
    shDir="/home/smbPublic"


    [ -d $phpDir ] || git clone https://github.com/alexantr/filemanager.git $phpDir
    sed -i "s#'fm_admin' => 'fm_admin'#//&#; /\/\/'fm_admin' => 'fm_admin'/ a\    \'$user\' => \'$mypwd\'," $php

    sed -i "/^\$root_path = \$_SERVER\[/ a \$root_path = \'$shDir\';" $php

    httpConf="/etc/httpd/conf.d/phpFileShare.conf"

    echo "Alias /index.php $php" > $httpConf

}

function main(){
    local dir=$localdir
    lsudo ln -sf ${dir}/httpShare.sh /usr/bin/httpShare.sh
    phpFileShare
}

main

