#!/usr/bin/python

import qrcode
import binascii

img = qrcode.make('pangwz:159 666 19200')
print type(img)
img.save(open('./ssssss.png','w'))
