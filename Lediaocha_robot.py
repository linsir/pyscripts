#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2015-11-09 11:16:01
# @Author  : linsir (root@linsir.org)
# @Link    : http://linsir.org
# 乐调查自动填问卷调查脚本

import urllib
import urllib2
import cookielib
import re
import random

class Le_robot:
    def __init__(self,url):
        self.post_url = url
        self.cookieFile = "cookies_saved.txt";
        self.cookie = cookielib.LWPCookieJar(self.cookieFile);
        #will create (and save to) new cookie file
        self.opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(self.cookie))
        self.opener.addheaders = [("User-agent","MMozilla/5.0 (X11; Linux x86_64)\
         AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36")]
        

    def open_via_cookies(self, url):
        response = self.opener.open(url)
        html = response.read()
        # fp = open("1.html","wb")
        # fp.write(html)
        # fp.close
        self.html = html
        return html

    def get_keys(self, html):

        auth = re.compile(r'name="auth" value="(.+?)" />').findall(self.html)[0]
        action = re.compile(r'name="action" value="(.+?)" />').findall(self.html)[0]
        t = re.compile(r'name="t" value="(.+?)" />').findall(self.html)[0]

        return auth,action,t

    def get_questions(self):
        self.open_via_cookies(self.post_url)
        q_lists = re.compile(r'name="(.+?)".+? value="(.+?)"').findall(self.html)
        qa = {}
        for x in q_lists:
            if qa.has_key(x[0]):
                qa[x[0]].append(x[1])
            else:
                qa[x[0]] = [x[1]]
                if len(x[0]) == 64:
                    qa[x[0]].append("0")

        return qa

    def submit(self):
        data = self.get_questions()
        submit_data = {}
        submit_data['auth'], submit_data['action'], submit_data['t'] = self.get_keys(self.html)
        for question, answer in data.items():
            submit_data[question] = random.choice(answer)
        for key, value in submit_data.items():
            if value == '0':
                del submit_data[key]
        # for key, value in submit_data.items():
        #     print key, ':', value
        request = urllib2.Request(self.post_url)
        request.add_header("Origin", "http://www.lediaocha.com")
        request.add_header("Referer", self.post_url)
        html = self.opener.open(request, urllib.urlencode(submit_data)).read()
        # print html





if __name__ == '__main__':
    url = "http://www.lediaocha.com/pc/s/1y5gab"
    url = "http://www.lediaocha.com/pc/s/1ojf52"
    app = Le_robot(url)
    # app.submit()
    for i in range(300):
        app.submit()
        print "OK，成功填写 %s 份！"%(i+1)

