#!/bin/bash
sslocal -q -d restart -s us01.jiasudu.biz -p 10355 -k 7303 -m aes-256-cfb -b 0.0.0.0 -l 1080 --pid-file /home/pangwz/tools/toolsMisc/./shadowsocks/ss.pid --log-file /home/pangwz/tools/toolsMisc/./shadowsocks/ss.log
