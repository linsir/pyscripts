#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear
echo "# auto gen ssh key  and upload to remote server "
echo "# Author: linsir"
echo "# blog: linsir.org"

function confirm() {
    # Usage: x=$(confirm "do you want to continue?")
    #        if [ "$x" = "yes" ]
    QUESTION="$1"
    read -p "${QUESTION} [yN] " ANSWER
    if [[ "${ANSWER}" == "y" ]] || [[ "${ANSWER}" == "Y" ]]
    then
        echo "yes"
    else
        echo "no"
    fi
}

function get_base_info(){
    read -p "Please input config name:" config
    if [ "$config" = "" ];then
       config_name=`echo ~/.ssh/config`
    else
       config_name=`echo ~/.ssh/config.d/$config`
    fi
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
    use_key=$(confirm "Using ssh key login?")
    if [ "$use_key" = "no" ];then
        read -p "Password(default value:):" password
    fi
    echo "####################################"
    echo "Please confirm the information:"
    echo ""
    echo -e "the server name: [\033[32;1m$server_name\033[0m]"
    echo -e "ssh info: [\033[32;1m$user@$ip:$port\033[0m]"
    echo -e "use key: [\033[32;1m$use_key\033[0m]"
    echo -e "password: [\033[32;1m$password\033[0m]"
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
        read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'
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
    cat >> $config_name<<-EOF
Host $server_name
    hostname $ip
    user $user
    port $port
    Password $password
    IdentityFile ~/.ssh/$1

EOF
}

function main(){
    get_base_info
    if [ "$use_key" = "yes" ];then
        copy_key_remote
    else
        add_config id_rsa
    fi
    
}

main
exit
