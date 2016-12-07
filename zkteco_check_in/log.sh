#!/bin/bash
# @Date    : 2016-06-07 16:04:54
# @Author  : Linsir (root@linsir.org)
# @Link    : http://linsir.org
# @Version : 0.2
# 2008 2010 2055

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 随机生成范围的数字
function rand(){
    local beg=$1
    local end=$2
    echo $((RANDOM % ($end - $beg) + $beg))
}

function del_log(){
    echo "==========================="
    log_id=$1
    old_time=`./sqlite3_mips ZKDB.db "SELECT Verify_Time FROM ATT_LOG WHERE ID = '${log_id}';"`
    user_id=`./sqlite3_mips ZKDB.db "SELECT User_PIN FROM ATT_LOG WHERE ID = '${log_id}';"`
    if [ "${user_id}" = ""]; then
        echo -e "[\033[32;1mError\033[0m]: Bad [log_id], please try again"
        menu
        exit
    fi
    name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${user_id}'"`
    echo -e "Are you sure delete the log: [\033[32;1m${name}: ${old_time}\033[0m] "
    read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'
    ./sqlite3_mips ZKDB.db "DELETE FROM ATT_LOG WHERE ID = '${log_id}'"
    echo -e "[\033[32;1mDelete Sucessfuly\033[0m]"
    ./sqlite3_mips ZKDB.db ".quit"
}

function query_id(){
    echo "==========================="
    name=$1
    user_id=`./sqlite3_mips ZKDB.db "SELECT User_PIN FROM USER_INFO WHERE NAME = '${name}'"`
    if [ "${user_id}" = ""]; then
        echo -e "[\033[32;1mError\033[0m]: Bad [name], please try again"
        menu
        exit
    fi
    echo -e "[\033[32;1m${name}\033[0m]'s ID is [\033[32;1m${user_id}\033[0m] "
    ./sqlite3_mips ZKDB.db ".quit"
}

function check_in(){
    echo "==========================="
    user_id=$1
    name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${user_id}'"`
    if [ "${name}" = ""]; then
        echo -e "[\033[32;1mError\033[0m]: Bad [user_id], please try again"
        menu
        exit
    fi
    echo -e "签到用户: [\033[32;1m${name}\033[0m]"

    today=$(date '+%Y-%m-%d')

    new_time="08:"$(rand 55 59)":"$(rand 10 59)
    DateTime=$today"T"$new_time

    echo -e "the datetime:[\033[32;1m${DateTime}\033[0m]"
    read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'

    # echo "签到时间: ${DateTime}"
    ./sqlite3_mips ZKDB.db "INSERT INTO ATT_LOG VALUES (null,'${user_id}',15,'${DateTime}','0','0',null,null,null,null,0);"
    save_time=`./sqlite3_mips ZKDB.db "SELECT Verify_Time FROM ATT_LOG WHERE User_PIN = '${user_id}' ORDER BY ID DESC LIMIT 0,1;"`
    echo -e "[\033[32;1m${name}\033[0m] 签到时间: [\033[32;1m${save_time} Sucessfuly\033[0m]"
    ./sqlite3_mips ZKDB.db ".quit"
}

function change_log(){
    echo "==========================="

    read -p "请输入签到用户工号(默认用户ID 2055): " user_id
    if [ "${user_id}" = "" ]; then
        user_id=2055
    fi
    name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${user_id}'"`
    if [ "${name}" = ""]; then
        echo -e "[\033[32;1mError\033[0m]: Bad [user_id], please try again"
        menu
        exit
    fi
    echo -e "签到用户: [\033[32;1m${name}\033[0m] (${user_id})"
    Month=$(date '+%Y-%m%')
    
    ./sqlite3_mips ZKDB.db "SELECT ID,User_PIN,Verify_Time FROM ATT_LOG WHERE User_PIN = '${user_id}' and Verify_Time like '${Month}';"
    read -p "请输入更改签到的[ID]: " ID
    if [ "${ID}" = "" ]; then
        exit 0
    fi

    if [ "$1" = "" ]; then
        echo $1
        read -p "请输入签到的日期[2016-06-06](默认今天): " today
        if [ "${today}" = "" ]; then
            # Date=$(date '+%Y-%m-%dT%H:%M:%S')
            today=$(date '+%Y-%m-%d')
        fi
        new_time="08:"$(rand 55 59)":"$(rand 10 59)
        DateTime=$today"T"$new_time
    else
        DateTime=$1
    fi
    old_time=`./sqlite3_mips ZKDB.db "SELECT Verify_Time FROM ATT_LOG WHERE ID = '${ID}';"`
    if [ "${old_time}" = ""]; then
        echo -e "[\033[32;1mError\033[0m]: Bad [log_id], please try again"
        menu
        exit
    fi
    echo -e "Are you sure to change [\033[32;1m${old_time}\033[0m] into [\033[32;1m${DateTime}\033[0m]?"
    read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'

    ./sqlite3_mips ZKDB.db "UPDATE ATT_LOG SET Verify_Time = '${DateTime}' WHERE ID = '${ID}';"
    echo -e "[\033[32;1mChange Sucessfuly\033[0m]"
    # ./sqlite3_mips ZKDB.db "SELECT ID,User_PIN,Verify_Time FROM ATT_LOG WHERE ID = '${ID}';"
    ./sqlite3_mips ZKDB.db ".quit"
}

function change_finger(){
    echo "==========================="
    old_user_id=$1
    new_user_id=$2
    if [ "${old_user_id}" = "" -a "${new_user_id}" = "" ]; then
        echo -e "[\033[32;1mError\033[0m]: Bad option, please choose again"
        menu
        exit
    fi
    old_name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${old_user_id}'"`
    new_name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${new_user_id}'"`
    if [ "${old_name}" = "" -a "${new_name}" = "" ]; then
        echo -e "[\033[32;1mError\033[0m]: Bad [ID], please try again"
        menu
        exit
    fi
    old_user_defaulf_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM USER_INFO WHERE User_PIN = '${old_user_id}'"`
    new_user_defaulf_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM USER_INFO WHERE User_PIN = '${new_user_id}'"`
    finger_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM fptemplate10 WHERE pin = '${old_user_defaulf_id}' limit 1"`
    if [ "${finger_id}" = "" ]; then
        echo -e "[\033[32;1mError\033[0m]: the user [\033[32;1m${old_name}\033[0m] have no finger data, please try again"
        menu
        exit
    fi
    finger_type=`./sqlite3_mips ZKDB.db "SELECT fingerid FROM fptemplate10 WHERE ID = '${finger_id}'"`
    echo -e "用户: [\033[32;1m${old_name}\033[0m] => [\033[32;1m${new_name}\033[0m] fingerid([\033[32;1m${finger_type}\033[0m])"
    read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'
    echo "UPDATE fptemplate10 SET pin = '${new_user_defaulf_id}' WHERE ID = '${finger_id}';"

}
function menu(){
    echo "==========================="
    echo "# @Author  : Linsir (root@linsir.org)"
    echo "# @Link    : http://linsir.org"
    echo "# @Version : 0.2"
    echo "Bad option, please choose again"
    echo "Usage: 1. bash $0 query [Name]: Query user's ID."
    echo "       2. bash $0 checkin [ID]: Check in for [ID]'s user."
    echo "       3. bash $0 change: Change checkin time of current month."
    echo "       4. bash $0 change [time] (2016-06-06T16:03:50): Change checkin time of current month with [time]."
    echo "       5. bash $0 del [ID]: Delete the [ID]'s checkin log."
    echo "       6. bash $0 help [ID1] [ID2]: Use [ID1]'finger help [ID2] to checkin.' "
}

function Usage(){
    while [ $# != 0 ]
    do
        case $1 in
            "query" )
                query_id $2
                exit
            ;;
            "checkin" )
                check_in $2
                exit
            ;;
            "change" )
                change_log $2
                exit
            ;;
            "del" )
                del_log $2
                exit
            ;;
            "help" )
                change_finger $2 $3
                exit
            ;;
            * )
            menu
            exit
        esac
    done
    menu
}

Usage "$@"
