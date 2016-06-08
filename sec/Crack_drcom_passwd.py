#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2015-10-28 10:55:46
# @Author  : linsir (root@linsir.org)
# @Link    : http://linsir.org
# drcom早期版本密码解密脚本

def encode(string):
    diff=[28,57,86,19,47,76,9,38,66,95,28,57,86,18,47,76]
    passwd = [ord(i) for i in string]
    print passwd
    diff=diff[0:len(passwd)]

    f = [x + y for x, y in zip(passwd, diff)]
    result = [i - 95 if i>= 126 else i for i in f]
    result = [chr(i) for i in result]
    result.append('a')
    return "".join(result)

def decode(passwd):
    diff=[28,57,86,19,47,76,9,38,66,95,28,57,86,18,47,76]
    passwd = [ord(i) for i in passwd[:-1]]
    diff=diff[0:len(passwd)]

    f = [x - y for x, y in zip(passwd, diff)]
    result = [i + 95 if i<= 32 else i for i in f]
    result = [chr(i) for i in result]
    return "".join(result)


if __name__ == '__main__':
    print encode("123456")
    # pwd = 'Tq/Kg%a'
    # # pwd = 'Ml,Hg"?Ya'
    # print decode(pwd)
