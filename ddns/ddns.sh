#!/bin/sh

# sddns, a dnspod ddns client for linux and FreeBSD.
# Written by vinoca, June 2013
# Distributed under the MIT License
#
# more visit www.vinoca.org

VERSION=0.0.9.1
SIGN="sddns/$VERSION(vinoca@vinoca.org)"

config_file="./sddns.conf"

# load config file
[ ! -w $config_file ] && echo "ERROR: config file \"$config_file\" does not exist or have not write permission." && exit 1
. $config_file

type curl 2>&1 >/dev/null || { echo "ERROR: \"curl\" is not in your system.";exit 1;}

# check $wanip
[ -z "$wanip" ] &&  echo "ERROR: Please check \"$config_file\", \"wanip\" is invalid ." && exit 1
# this regular expression from http://www.regular-expressions.info/examples.html
cur_wanip=`curl -sL $wanip | grep -Eo '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'`
[ -z "$cur_wanip" ] && ignore_wanip=1 && echo "WARNING: \"wanip\" is invalid." 

# wrap some routines
post() {
	curl $addon_opt -sL -A $SIGN --data "login_email=$login_email&login_password=$login_password&format=json&error_on_empty=no&$1" "https://dnsapi.cn/$2"
}

get_domain_id() {
	sed -rn 's/.*("domain":\{.[^}]+\}).*/\1/g;s/.*"id":"([0-9]+)".*/\1/p'
}

get_record_id() {
	sed -rn "s/.*(\"records\":\[.[^]]+\]).*/\1/g;s/.*\{\"id\":\"([0-9]+)\",\"name\":\"$1\".*\"type\":\"A\".*/\1/p"
}

save_value() {
		grep "$1" $config_file >/dev/null 2>&1 || { echo "$1=$2" >> $config_file; return 0; }
		sed -i "s/$1=.*/$1=$2/g" $config_file
}		

# save domain_id and record_id if that is not in config_file 
#
[ -z "$domain_id" ] && {
	domain_id=`post "domain=$main_domain" Domain.Info | get_domain_id`
	save_value domain_id $domain_id
}

[ -z "$record_id1" ] && {
	[ -z "$sub_domain" ] && echo "ERROR: Please check \"$config_file\", \"sub_domain\" is invalid ." && exit
	num_sub_domain=$((`echo $sub_domain | tr -cd ',' | wc -c`+1))
	save_value num_sub_domain $num_sub_domain
	for i in `seq $num_sub_domain`; do
		sd_str=`echo $sub_domain | cut -d ',' -f$i`
		eval sd$i=$sd_str
		eval record_id$i=`post "domain_id=$domain_id" Record.List | get_record_id $sd_str`
		save_value sd$i $sd_str
		save_value record_id$i `eval echo $\record_id$i`
	done
}

# update subdomain record if wanip is changed.
#
[ -z $ignore_wanip ] && [ "$cur_ip" = "$cur_wanip" ] && exit 0
save_value cur_ip $cur_wanip
for i in `seq $num_sub_domain`; do
	s=`eval echo \\$sd$i`
	n=`eval echo \\$record_id$i`
	post "domain_id=$domain_id&record_id=$n&sub_domain=$s&record_line=默认" Record.Ddns
done
exit 2

# vim: set ts=2 sw=2 noet:
