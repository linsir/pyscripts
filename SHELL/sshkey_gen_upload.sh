#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear

echo "# auto gen ssh key  and upload to remote server "
echo "# Author:linsir"
echo "# linsir.org"
echo ""

# sshkey gen
read -p "pls input a note for key:" note
echo $note 

if [ "$note" = "" ];then
    exit 
    # ssh-keygen -t rsa
else
    if [ -f ~/.ssh/$note ];then
        echo "the key exist!use old key"
    else
        ssh-keygen -t rsa -C $note -f ~/.ssh/$note
    fi
fi

# ssh-agent bash
ssh-add ~/.ssh/$note

# copy the key to remote server

read -p "pls input ip adderss of server:" ip
read -p "pls input username of server:" user
read -p "pls input sshd port of server:" port

if [ "$port" = "" ];then
    port=22
fi
if [ "$user" = "" ] && [ "$ip" = "" ];then
    exit 
else
    ssh-copy-id -o PubkeyAuthentication=no -i ~/.ssh/$note.pub -p $port $user@$ip
fi

# config ssh config

 cat >> ~/.ssh/config<<-EOF
Host $note
    hostname $ip
    user $user
    port $port
    IdentityFile ~/.ssh/$note
EOF
exit
