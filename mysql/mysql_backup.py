#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2016-04-13 09:38:20
# @Author  : Linsir (root@linsir.org)
# @Link    : http://linsir.org
# @Version : 0.1

import subprocess
import time
from datetime import datetime, timedelta
import logging

backup_file_path = "/home/data/mysqlbak"
# backup_file_path = "./"
data = [
    {
        "db_host": "127.0.0.1",
        "db_name": "db1",
        "db_user": "user",
        "db_password": "password",
    },
    {
        "db_host": "127.0.0.1",
        "db_name": "dbv2",
        "db_user": "user",
        "db_password": "password",
    },
]

# 格式化时间, 默认返回当前时间
def fmt_time(fmt='%Y-%m-%d %H:%M:%S', seconds=None):
    if not seconds: seconds = time.time()
    t = datetime.utcfromtimestamp(seconds)
    t = t + timedelta(hours=+8) # 时区
    return t.strftime(fmt)

log_name = '%s/mysql_backup_%s.log'%(backup_file_path, fmt_time('%Y-%m-%d'))
logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s %(levelname)s %(message)s',
        datefmt='%m/%d/%Y %H:%M:%S',
        filename=log_name,
        filemode='w',
        )

def backup_db(db_name, db_user, db_password, db_host='127.0.0.1'):
    time = fmt_time('%Y-%m-%d')
    db_filename = "%s/%s_%s_sql.gz" %(backup_file_path, db_name, time)
    command = "mysqldump -h%s -u%s -p%s %s |gzip >%s " %(db_host, db_user, db_password, db_name, db_filename)
    p = subprocess.Popen(command, shell=True, stderr=subprocess.PIPE)
    info = p.stderr.read()
    if  info == '':
        logging.info("Backup %s Sucessful..."%db_name)
        return '%s : Sucess\n'%db_name
    else:
        logging.error("Failed to backup %s ..."%db_name)
        logging.error(info)
        command = 'rm -f %s'%db_filename
        subprocess.call(command,shell=True)
        return '%s : Failed\n'%db_name

def backup_from_list(list=data):
    starttime = time.time()
    line = "\n----------------------\n"
    backup_result = ''
    logging.info(line + 'Backup stared..')
    for db in data:
        db_name = db["db_name"]
        db_user = db["db_user"]
        db_password = db["db_password"]
        db_host = db['db_host']
        backup_result = backup_result + backup_db(db_name,db_user,db_password,db_host)
    ###
    delete_expires_files()
    endtime = time.time()
    time_info = line + "Total used time: %.2fs." %(endtime - starttime)
    logging.info(line + backup_result + time_info)
    return backup_result

def delete_expires_files(day=7):
    command = 'find %s \( -name "*_sql.gz" -or -name "*.log" \) -type f +mtime +%s -exec rm -f {} \;' %(backup_file_path, day)
    subprocess.Popen(command, shell=True, stderr=subprocess.PIPE)
    info = "Already delelte the expires files %s days ago.."%day
    logging.info(info)

if __name__ == '__main__':
    backup_from_list()
    # delete_expires_files()
    # print fmt_time()
    # backup_db("db_name", "db_user", "db_password")
    # delete_expires_files()

