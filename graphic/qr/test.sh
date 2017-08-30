#!/usr/bin/bash

tmp=`mktemp --dry-run -t qrTst-XXXXXXXX`

qrencode 'pangwz:159 666 19200' -o $tmp

zbarimg --raw -d $tmp

rm $tmp
