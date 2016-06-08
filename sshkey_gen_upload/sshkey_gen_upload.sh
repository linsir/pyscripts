#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear
echo "# auto gen ssh key  and upload to remote server "
echo "# Author: linsir"
echo "# blog: linsir.org"

function get_base_info(){
    read -p "Please input a server name:" server_name
    if [ "$server_name" = "" ];then
        exit
    fi 
    read -p "ip adderss of server:" ip
    if [ "$ip" = "" ];then
        exit
    fi 
    read -p "sshd port of server(default value:22):" port
    read -p "username of server(default value:root):" user

    if [ "$port" = "" ];then
        port=22
    fi
    if [ "$user" = "" ];then
        user=root
    fi
    echo "####################################"
    echo "Please confirm the information:"
    echo ""
    echo -e "the server name: [\033[32;1m$server_name\033[0m]"
    echo -e "ssh info: [\033[32;1m$user@$ip:$port\033[0m]"
}

function get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
}
# sshkey gen
function create_key(){
    if [ -f ~/.ssh/$1 ];then
        echo "the key exist!use old key"
    else
        echo "create keys $1 now ..."
        ssh-keygen -t rsa -C $1 -f ~/.ssh/$1
        ssh-add ~/.ssh/$1
    fi
}


# copy the key to remote server
function copy_key_remote(){
    while true; do
        echo -e "Do you wish to use the default key([\033[32;1mid_rsa/id_rsa.pub\033[0m]),otherwise will create new keys.y/n:\c"
        read yn
        echo "Press any key to start...or Press Ctrl+C to cancel"
        char=`get_char`
        case $yn in
            [Yy]* ) default_key=1; break;;
            [Nn]* ) default_key=0; create_key $server_name; break;;
            * ) default_key=1; break;;
        esac
    done

    if [ $default_key -eq 1 ];then
        echo -e "use default_key [\033[32;1mid_rsa/id_rsa.pub\033[0m].."
        create_key id_rsa
        copy_now id_rsa
        local RET=$?
        echo $RET
        if [ $RET -eq 0 ];then
            add_config id_rsa
            exit 1
        else
            exit 0
        fi
    else
        echo 'use new key...'
        create_key $server_name
        copy_now $server_name
        local RET=$?
        if [ $RET -eq 0 ];then
            add_config $server_name
            exit 1
        fi
    fi
}

function copy_now(){
    ssh-copy-id -i ~/.ssh/$1.pub  -p$port -o PubkeyAuthentication=no $user@$ip
    local RET=$?
    if [ $RET -ne 0 ];then
        
        ssh-copy-id -i ~/.ssh/$1.pub  "-p$port -o PubkeyAuthentication=no $user@$ip"
    fi
}
function add_config(){
    echo "add configure to .ssh/config.."
    cat >> ~/.ssh/config<<-EOF
Host $server_name
    hostname $ip
    user $user
    port $port
    IdentityFile ~/.ssh/$1

EOF
}

function main(){
    get_base_info
    copy_key_remote

}

main
exit
