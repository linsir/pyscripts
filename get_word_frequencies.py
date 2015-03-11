#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2015-03-11 14:08:36
# @Author  : Linsir (vi5i0n@hotmail.com)
# @Link    : http://Linsir.sinaapp.com

import re

def get_word_frequencies(file_name):
    dic = {}
    txt = open(file_name, 'r').read().splitlines()
    # print txt
    for line in txt:
        line = re.sub(r'[^\u4e00-\u94a5\w\d\-]', ' ', line)
        line = re.sub(r"[^a-zA-Z'-]|\\s+|\t|\r", ' ', line)
        line = re.sub(r"-{2,}", ' ', line)
        line = re.sub(r"'{2,}", ' ', line)
        for word in line.split():
            dic.setdefault(word.lower(), 0)
            dic[word.lower()] += 1
    li= sorted(dic.iteritems(), key=lambda d:d[1], reverse = True)
    print dic
    for i in li:
        print i 
    
if __name__ == '__main__':
    get_word_frequencies('test.txt')
