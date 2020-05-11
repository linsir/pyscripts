#!/usr/bin/env python
# -*- coding:utf-8 -*-
'''
@Description: 
@Author: Linsir
@Github: https://github.com/linsir
@Date: 2020-05-11 14:13:06
@LastEditors: Linsir
@LastEditTime: 2020-05-11 14:43:43
'''

import sys, json

res = sys.stdin.read()

try:
    data_list = json.loads(res)['domains']
except Exception as e:
    # print("not hit domains")
    pass

try:
    data_list = json.loads(res)['records']
except Exception as e:
    # print("not hit records")
    pass


for data in data_list:
    print("{}:{}".format(data["id"], data["name"]))