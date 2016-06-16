#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2016-04-25 13:46:38
# @Author  : Linsir (root@linsir.org)
# @Link    : http://linsir.org
# @Version :

import os
import getopt
import requests
import re
import urlparse
from time import sleep
from threading import Thread

import sys
reload(sys)
sys.setdefaultencoding( "utf-8" )

UPDATE_INTERVAL = 0.01

class URLThread(Thread):
    def __init__(self, url, timeout=10, allow_redirects=True):
        super(URLThread, self).__init__()
        self.url = url
        self.timeout = timeout
        self.allow_redirects = allow_redirects
        self.response = None


    def run(self):
        try:
            self.response = requests.get(self.url, timeout = self.timeout, allow_redirects = self.allow_redirects)
        except Exception , e:
            print e

class downloader(object):
    """
    Download any files or folders from repository in GitHub.
    """
    def __init__(self, url, path="./"):
        self.session = requests.Session()
        self.session.headers = {
            "User-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.75 Safari/537.36",
            "Origin": "https://github.com",
        }
        self.base_url = url
        self.all_files = {}
        self.path = path

    def get_files(self, url, path="./"):

        html = self.multi_get([url])[0][1].content
        files = re.compile(r'td class="content".+?<a href="(.+?)".+?</a>', re.DOTALL).findall(html)
        urls  = [ self.fix_file_url(url) for url in files ]
        for url in urls:
            now_path = self.is_dir(url)
            if now_path:
                self.get_files(url, now_path)
            else:
                filename = url.split("/")[-1]
                self.all_files[url] = path + "/" + filename
        return self.all_files

    def is_dir(self, url):
        url_dict = url.split('/')
        base_url_dict = self.base_url.split('/')
        length = len(base_url_dict)
        if url_dict[5] == 'tree':
            ret = url_dict[length:]
            if "tree" not in base_url_dict:
                ret = ret[2:]
            return "/".join(ret)
        else:
            return None

    def fix_file_url(self,url):
        url = 'https://github.com' + url
        return url.replace('blob', 'raw')

    def multi_get(self, uris, timeout=10, allow_redirects=True):
        '''
        uris    文件列表
        timeout 访问url超时时间
        allow_redirects 是否url自动跳转
        '''
        def alive_count(lst):
            alive = map(lambda x : 1 if x.isAlive() else 0, lst)
            return reduce(lambda a,b : a + b, alive)
        threads = [ URLThread(uri, timeout, allow_redirects) for uri in uris ]
        for thread in threads:
            thread.start()
        while alive_count(threads) > 0:
            sleep(UPDATE_INTERVAL)
        return [ (x.url, x.response) for x in threads ]

    def _path(self, file_name):

        folder = os.path.split(file_name)[0]
        if not os.path.exists(folder):
            os.makedirs(folder)
        return file_name

    def save(self, data):
        prefix = self.base_url.split("/")[-1]
        for url, r in data:
            file_name = prefix + '/' + self.all_files[url]
            with open(self._path(file_name), "wb") as code:
                 code.write(r.content)

    def run(self):
        print "Get files list ..."
        all_files = self.get_files(self.base_url, self.path)
        # print all_files
        print "Download now ..."
        uris = all_files.keys()
        data = self.multi_get(uris)
        self.save(data)
        print "Save Data Sucessfully."

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg

def help_msg():
    print("Author: Linsir(https://linsir.org)")
    print("Download any files or folders from repository in GitHub.")
    print("Usage: github_downloader.py -o [save path] [github url] ")

    sys.exit(0)

def main(argv=None):
    if argv is None:
        argv = sys.argv

    try:
        out_path = "./"
        url = None
        try:
            opts, args = getopt.getopt(argv[1:], "ho:", ["help"])
            for op,value in opts:
                if op in ("-h","-H","--help"):
                    help_msg()
                if op == "-o":
                  out_path = value
            if args:
                url = args[0]
        except getopt.error, msg:
             raise Usage(msg)
        # more code, unchanged
        if url:
            app = downloader(url,out_path)
            app.run()
    except Usage, err:
        print >>sys.stderr, err.msg
        print >>sys.stderr, "for help use --help"
        return 2


if __name__ == '__main__':
    # url = 'https://github.com/onlylemi/download-any-for-github'
    # url = 'https://github.com/vi5i0n/ngx-lua-images/tree/master/ngx-lua-images'
    # url = 'https://github.com/vi5i0n/Pastebin/tree/master/static'
    # app = downloader(url)
    # app.run()
    sys.exit(main())
