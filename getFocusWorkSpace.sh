#!/bin/sh

pyName=/tmp/getFocusWorkSpace.py

cat << EOF > $pyName
#!/bin/env python

import sys
import os
import json

jsonStr=os.popen('i3-msg -t get_workspaces').readline()
dicts = json.loads(jsonStr)                                                             
for d in dicts:
    if d['focused'] == True:
        print d['num']
EOF

chmod a+x $pyName
curWorkSpace=$($pyName)
echo $curWorkSpace
#rm $pyName
