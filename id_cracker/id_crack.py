#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2016-11-16 09:54:57
# @Author  : Linsir (root@linsir.org)
# @Link    : http://linsir.org
# @Version : 
# 身份号的生成算法：6位地址码+8位出生日期码+3位顺序码+1位校验码，
# 其中3位顺序码属于随机生成「顺序码是给同地址码同出生日期码的人编定的顺序号，
# 其中奇数分配给男性，偶数分配给女性」，其它位都是可以通过条件得知。那么，最多发起500个网络请求，就能还原一个身份证号。
# 在线验证 API Docs: http://www.id98.cn/doc/idcard
# Sex:M:1 or F:0

import json
import requests

DB_FILE = 'city_data.json'
APP_KEY = '6be2b332ba7d24c29539ec0fbb064421'

class IDCard(object):
    """docstring for IDCard"""
    def __init__(self):
        with open(DB_FILE, 'r') as f:
            self.data = json.load(f)
        
    def gen_num(self, sex):
        if sex == '0':
            for x in xrange(0, 1000, 2):
                if len(str(x)) == 1:
                    yield '00' + str(x)
                elif len(str(x)) == 2:
                    yield '0' + str(x)
                else:
                    yield str(x)
        elif sex == '1':
            for x in xrange(1, 1000, 2):
                if len(str(x)) == 1:
                    yield '00' + str(x)
                elif len(str(x)) == 2:
                    yield '0' + str(x)
                else:
                    yield str(x)
        else:
            return

    def get_location(self, addr):
        return self.data[addr]

    def has_location(self, addr):
        return self.data.has_key(addr)

    def get_checkcode(self, id):
        if len(id) != 17:
            return 
        weight = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        id_sum = reduce(
            lambda x, y: x + y,
            map(
                lambda x, y: x * y,
                [int(x) for x in id],
                weight))
        mod = id_sum % 11
        CountRule = {
            '0': '1',
            '1': '0',
            '2': 'X',
            '3': '9',
            '4': '8',
            '5': '7',
            '6': '6',
            '7': '5',
            '8': '4',
            '9': '3',
            '10': '2'}
        checkcode_value = CountRule.get(str(mod), None)
        return checkcode_value

    def gen_id(self, addr, birthday, sex):
        if not self.has_location(addr):
            return
        for x in self.gen_num(sex):
            pre_id = addr + birthday + x
            checkcode = self.get_checkcode(pre_id)
            yield pre_id + checkcode

    def validation_id_net(self, id, name):
        data = {
            "cardno": id,
            "name": name,
            "appkey": APP_KEY
        }
        url = 'http://api.id98.cn/api/idcard'
        # url = 'http://httpbin.org/get'
        r = requests.get(url, params=data)
        return r.json()

    def validation_id(self, id):
        if not self.has_location(id[:6]):
            return False
        if self.get_checkcode(id[:-1]) == id[-1]:
            return True
        else:
            return False

if __name__ == '__main__':
    id = '350626198701084431'
    name = '邓超'
    app = IDCard()
    # app.get_checkcode(id[:-1])
    # print app.get_location(id[:6])['address']
    # print app.has_location(id[:6])
    # print app.validation_id(id)
    # for x in app.gen_id('350626', '19870108', '0'):
    #     print x
    print app.validation_id_net(id, name)

