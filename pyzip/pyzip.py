#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
说明：解决解压zip中文件名乱码
安装：sudo cp pyzip.py /usr/bin/pyzip && sudo chmod +x /usr/bin/pyzip
用法：pyzip filename
'''
import os
import sys
import zipfile

def unzip(list):

    for filename in list:
        print "Processing File: %s" %filename
        file = zipfile.ZipFile(filename,"r");
        file_list = file.namelist()
        if file_list[0].endswith('/') and (file_list[0] == file_list[-1]):
            pre_folder = ''
        else:
            pre_folder = filename.strip('.zip') + '/'

        for name in file_list:
            utf8name = pre_folder + name.decode('gbk')
            print "Extracting %s" %utf8name 
            pathname = os.path.dirname(utf8name)
            if not os.path.exists(pathname) and pathname!= "":
                os.makedirs(pathname)
            data = file.read(name)
            if not os.path.exists(utf8name):
                fo = open(utf8name, "w")
                fo.write(data)
                fo.close
        file.close()
    print 'Extract Sucess!'
if __name__ == '__main__':
    if len(sys.argv) < 2:
        print "Usage:"+" pyzip.py "+"file_list or single zipfile."
        sys.exit()
    unzip(list = sys.argv[1:])