#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2015-05-15 19:27:50
# @Author  : Linsir (root@linsir.org)
# @Link    : http://linsir.org
# import xml.etree.ElementTree as ET
import xlsxwriter

# Create a workbook and add a worksheet.
workbook = xlsxwriter.Workbook('test.xlsx')
worksheet = workbook.add_worksheet()
 
import json

f = file("test.json");
s = json.load(f)
row = 0
col = 0
for (d,x) in s.items():
    worksheet.write(row, col, int(d))
    print d
    col = col + 1
    for data in x:
        print data
        worksheet.write(row, col, data)
        col += 1
    # Write a total using a formula.
    worksheet.write(row, col, '=SUM(C%d:E%d)'%(row + 1,row + 1) )
        
    col = 0    
    row += 1

workbook.close()

