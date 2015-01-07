#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2015-01-07 09:31:57
# @Author  : Linsir (vi5i0n@hotmail.com)
# @Link    : http://Linsir.sinaapp.com


#生成随机密码存入Mongodb, MySQL
import time
from datetime import datetime, timedelta
import random
import string

def activation_code(id,length=10):
    '''
    id + L + 随机码
    '''
    pre = hex(id)[2:] + 'L'
    length = length - len(pre)
    chars=string.ascii_letters+string.digits
    return pre + ''.join([random.choice(chars) for i in range(length)])

def get_id(code):
    return str(int(code.upper(), 16))

def save_mongodb():
    from pymongo import Connection
    conn = Connection('127.0.0.1',27017)
    db = conn.codes   #连接test中的codes集合，相当于MySQL中的表
    db.codes.drop()
    for i in range(10,400,35):
        code = activation_code(i)
        deadtime = time.time() + timedelta(hours=+12).seconds
        db.codes.insert({
            "id": i,
            "code": code,
            "deadtime": deadtime,
            }
            )
    # 插入结果
    content = db.codes.find()
    for i in content:
        print i

def save_mysql():
    import MySQLdb
    conn=MySQLdb.connect(host='localhost',user='root',passwd='',db='test',port=3306)
    cur = conn.cursor()
    
    create_table = '''create table codes(
       id                    int not null auto_increment,
       codes                 varchar(50) not null,
       deadtime              varchar(50) not null,
       primary key (id)
    );'''
    cur.execute('drop table if exists codes;')
    cur.execute(create_table)
    for i in range(5):
        deadtime = time.time() + timedelta(hours=+12).seconds
        sql = '''insert into codes(codes, deadtime) values("Newcodes",%s)''' %deadtime
        cur.execute(sql)
        id = conn.insert_id()
        code = activation_code(id)
        update_sql = '''update codes set codes = "%s" where id = %s''' %(code, id)
        cur.execute(update_sql)

    cur.execute("select * from codes;")
    content =  cur.fetchall()
    for i in content:
        print i 
    cur.close()
    conn.commit()
    conn.close()

#格式化时间，默认输入当前时间
def fmt_time(seconds=None, fmt='%Y-%m-%d %H:%M:%S'):
    if not seconds: seconds = time.time()
    t = datetime.utcfromtimestamp(seconds)
    t = t + timedelta(hours=+8) # 时区
    return t.strftime(fmt)

if __name__=="__main__":
        # save_mongodb()
        save_mysql()