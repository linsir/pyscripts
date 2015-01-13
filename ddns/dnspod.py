#!/usr/bin/env python
# -*- coding: utf-8 -*-

 
import httplib, urllib
import re, urllib2, json
import socket, sys


domain = "linsir.tk"
sub_domain = ['@',]
email = "vi5i0n@qq.com"# replace with your email
password = "Vision"# replace with your password

class dnspod(object):
    """docstring for dnspod"""
    def __init__(self):
        self.params = {
            "login_email" : email,
            "login_password" : password,
            "format" : "json",
            "record_line" : "默认",
        }
    
    def get_public_ip(self):
        data = urllib2.urlopen("http://20140507.ip138.com/ic.asp").read()
        ip = re.search('\d+\.\d+\.\d+\.\d+',data).group(0)
        return ip

    def get_domain_ip(self):
        result=socket.getaddrinfo(domain,'http')[0][4][0]
        return result
    
    def post(self,method):
        headers = {"UserAgent":"Ddns Client/0.1.0(vi5i0n@hotmail.com)",
                    "Content-type": "application/x-www-form-urlencoded",
                    "Accept": "application/json, text/javascript, */*; q=0.01"
                    }
        conn = httplib.HTTPSConnection("dnsapi.cn")
        conn.request("POST", "/"+method, urllib.urlencode(self.params), headers)
        response = conn.getresponse()

        data = response.read()
        conn.close()
        return data

    def get_domain_id(self):
        self.params.update(dict(domain=domain))
        data = self.post("Domain.Info")
        data = json.loads(data)
        domain_id = data["domain"]["id"]
        return domain_id

    def get_record_id(self):
        record_ids = {}
        domain_id = self.get_domain_id()
        self.params.update(dict(domain_id=domain_id))
        data = self.post("Record.List")
        data = json.loads(data)
        # domain_id = re.search('\d{5,9}',data).group(0)
        for record in data["records"]:
            if record["type"] == 'A':
                if record["name"] in sub_domain:
                    name = record["name"]
                    record_ids[name] = record["id"]
                
        # print record_ids
        return record_ids

    def update_record(self, ip):
        ids = self.get_record_id()
        for sub in ids:
            self.params.update(dict(sub_domain=sub))
            self.params.update(dict(record_id=ids[sub]))
            self.params.update(dict(value=ip))
            data = self.post("Record.Ddns")
            data = json.loads(data)
        return data['status']['code']
               
 
if __name__ == '__main__':
    dns = dnspod()
    try:
        domain_ip = dns.get_domain_ip()
        public_ip = dns.get_public_ip()
        if domain_ip != public_ip:
            if dns.update_record(public_ip):
                print "Okay,updated with: %s!" %public_ip
        print "The IP:%s is right now." %public_ip
    except:
        print "Domain or Network Conncetion Error!Please check it out!"
