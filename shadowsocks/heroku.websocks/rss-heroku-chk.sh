#!/usr/bin/bash

function check(){
    local service="rss-heroku.service"
    status=$(systemctl is-active $service)
    if ! [ "$status" == "active" ];then
	systemctl restart $service
    fi
}

check
