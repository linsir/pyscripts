#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$HOME/bin
export PATH

# clear
echo "# auto gen ssh key  and upload to remote server "
echo "# Author: Linsir"
echo "# blog: https://linsir.org"

if [ ! -f "utils.sh" ];then
    echo "Download utils.sh to $CURRENT_DIR/utils.sh ."
    curl https://raw.githubusercontent.com/linsir/bash-utils/master/utils.sh -o utils.sh
    # chmod +x utils.sh
fi

# locate dir
BASEDIR=$(dirname "$0")
cd "$BASEDIR" || exit
CURRENT_DIR=$(pwd)

# source utils
source "${CURRENT_DIR}"/utils.sh

KEYS_NAME="keys_store"
KEYS_PATH="$HOME/.ssh/$KEYS_NAME/"

CONF_PATH="$HOME/.ssh/config.d/"

if_dir_not_exist_then_mkdir ${CONF_PATH}
if_dir_not_exist_then_mkdir ${KEYS_PATH}

function get_base_info(){

    read -p "Please input config name:" config
    string_trim ${config}
    if [ "$config" = "" ];then
       config_name=`echo $HOME/.ssh/config`
    else
       config_name=`echo ${CONF_PATH}$config`
    fi

    read -p "Please input a server name:" server_name
    if_empty_then_exit ${server_name} "param server_name required"

    read -p "ip adderss of server:" ip
    if_empty_then_exit ${ip} "param ip required"

    read -p "sshd port of server(default value:22):" port
    read -p "username of server(default value:root):" user
    port=$(if_empty_then_return_default "${port}" 22)
    user=$(if_empty_then_return_default "${user}" root)

    read -p "Password:" password
    string_trim ${password}

    use_key=$(confirm_yes "Using ssh key login?")

    string_trim ${server_name}
    string_trim ${ip}
    string_trim ${port}
    string_trim ${user}
    string_trim ${password}

    echo_separator
    echo "Please confirm the information:"
    echo ""
    echo -e "the server name: $GREEN$server_name$END"
    echo -e "ssh info: $GREEN$user@$ip:$port$END"
    echo -e "use key: $GREEN$use_key$END"
    echo -e "password: $GREEN$password$END"
    echo_separator
}

# ssh client config

function config_ssh_config(){
    if [ -e "$HOME/.ssh/config" ];then
        echo "IgnoreUnknown Password\n" >> $HOME/.ssh/config
        cat >> $HOME/.ssh/config<<-EOF
Host *
  StrictHostKeyChecking no
  ForwardAgent yes
  ServerAliveInterval 30
  ControlMaster auto
  ControlPath /tmp/ssh_mux_%h_%p_%r
  ControlPersist 600
  GSSAPIAuthentication no
  Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc
  HostKeyAlgorithms +ssh-dss
  KexAlgorithms +diffie-hellman-group1-

EOF

        echo "Include config.d/*" >> $HOME/.ssh/config
    fi

}

# sshkey gen
function create_key(){
    if [ $default_key -eq 1 ];then
        KEYS_PATH="$HOME/.ssh/"
    fi
    log_info $KEYS_PATH

    if_dir_not_exist_then_mkdir ${KEYS_PATH}


    if [ -f ${KEYS_PATH}$1 ];then
        echo "the key exist! use old key"
    else
        echo "create keys $1 now ..."
        ssh-keygen -t rsa -C $1 -f ${KEYS_PATH}$1
        ssh-add ${KEYS_PATH}$1
    fi
}


# copy the key to remote server
function copy_key_remote(){
    while true; do
        echo -e "Use default key(${GREEN}id_rsa/id_rsa.pub${END}), or new keys.y/n:\c"
        read yn
        case $yn in
            [Yy]* ) default_key=1; break;;
            [Nn]* ) default_key=0; create_key $server_name; break;;
            * ) default_key=1; break;;
        esac
    done

    if [ $default_key -eq 1 ];then
        echo -e "use default_key ${GREEN}id_rsa/id_rsa.pub${END}.."
        create_key id_rsa
        copy_now id_rsa
        local RET=$?
        echo $RET
        if [ $RET -eq 0 ];then
            add_config default
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
    if [ $default_key -eq 1 ];then
        KEYS_PATH="$HOME/.ssh/"
    fi

    # ssh-copy-id -i ${KEYS_PATH}$1.pub  -p$port -o PubkeyAuthentication=no $user@$ip
    log_info 'sshpass -p ${password} "/usr/bin/ssh-copy-id" -i ${KEYS_PATH}$1.pub  "-p$port -o PubkeyAuthentication=no $user@$ip"'
    sshpass -p $password ssh-copy-id -i ${KEYS_PATH}$1.pub  -p$port -o PubkeyAuthentication=no $user@$ip
    local RET=$?
    if [ $RET -ne 0 ];then
        
        sshpass -p $password "/usr/bin/ssh-copy-id" -i ${KEYS_PATH}$1.pub  "-p $port -o PubkeyAuthentication=no $user@$ip"
    fi
}

function add_config(){
    log_info "add configure to $config_name .."
    if [ "$use_key" == "yes" ] && [ "$1" != "default" ] ;then
        cat >> $config_name<<-EOF
Host $server_name
    hostname $ip
    user $user
    port $port
    Password $password
    IdentityFile ~/.ssh/$KEYS_NAME/$1

EOF
    else
    cat >> $config_name<<-EOF
Host $server_name
    hostname $ip
    user $user
    port $port
    Password $password
    IdentityFile ~/.ssh/id_rsa

EOF
    fi
}

function main(){
    get_base_info
    if [ "$use_key" = "yes" ];then
        copy_key_remote
    else
        add_config default
    fi
    
}

main
exit
