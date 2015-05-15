#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2015-05-15 20:50:52
# @Author  : Linsir (root@linsir.org)
# @Link    : http://linsir.org

try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET

tree = ET.ElementTree(file='sitemap.xml')
root = tree.getroot()

for child in root:
    # print child.tag,child.attrib
    for item in child:
        print item.tag,item.text
