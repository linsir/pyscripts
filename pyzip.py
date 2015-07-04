#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import zipfile

#print "Processing File " + sys.argv[1]
list = sys.argv[1:]
for filename in list:
    print filename
    file=zipfile.ZipFile(filename,"r");
    for name in file.namelist():
        utf8name=name.decode('gbk')
    #    print "Extracting " + utf8name
        pathname = os.path.dirname(utf8name)
        if not os.path.exists(pathname) and pathname!= "":
            os.makedirs(pathname)
        data = file.read(name)
        if not os.path.exists(utf8name):
            fo = open(utf8name, "w")
            fo.write(data)
            fo.close
    file.close()
