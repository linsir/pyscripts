#!/bin/bash
# @Date    : 2016-06-07 16:04:54
# @Author  : Linsir (root@linsir.org)
# @Link    : http://linsir.org
# @Version :
# 2008 2010 2055

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
}
# 随机生成范围的数字
function rand(){
    local beg=$1
    local end=$2
    echo $((RANDOM % ($end - $beg) + $beg))
}


function check_in(){
    echo "==========================="

    # read -p "请输入签到用户工号(默认用户ID:2010): " UserID
    # if [ "${UserID}" = "" ]; then
    #     UserID=2010
    # fi
    UserID=$1
    echo "签到用户: ${UserID}"
    ./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${UserID}'"
    # read -p "请输入签到的时间(默认今天)[2016-06-06T16:03:50]: " Date
    # if [ "${Date}" = "" ]; then
    #     # Date=$(date '+%Y-%m-%dT%H:%M:%S')
    #     Date=$(date '+%Y-%m-%d')
    # fi
    Date=$(date '+%Y-%m-%d')

    Time="08:"$(rand 55 59)":"$(rand 10 59)
    DateTime=$Date"T"$Time

    echo -e "the datetime:[\033[32;1m${DateTime}\033[0m]"
    echo "Press any key to start to check in...or Press Ctrl+C to cancel"
    char=`get_char`

    echo "签到时间: ${DateTime}"
    ./sqlite3_mips ZKDB.db "INSERT INTO ATT_LOG VALUES (null,'${UserID}',15,'${DateTime}','0','0',null,null,null,null,0);"
    ./sqlite3_mips ZKDB.db "SELECT * FROM ATT_LOG WHERE User_PIN = '${UserID}' ORDER BY ID DESC LIMIT 0,1;"
    echo -e "[\033[32;1mChange Sucessfuly\033[0m]"
    ./sqlite3_mips ZKDB.db ".quit"
}

function change_log(){
    echo "==========================="

    read -p "请输入签到用户工号(默认用户ID 2010): " UserID
    if [ "${UserID}" = "" ]; then
        UserID=2010
    fi
    echo "签到用户: ${UserID}"
    Month=$(date '+%Y-%m%')
    ./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${UserID}'"
    ./sqlite3_mips ZKDB.db "SELECT ID,User_PIN,Verify_Time FROM ATT_LOG WHERE User_PIN = '${UserID}' and Verify_Time like '${Month}';"
    read -p "请输入更改签到的[ID]: " ID
    if [ "${ID}" = "" ]; then
        exit 0
    fi
    read -p "请输入签到的时间[2016-06-06T16:03:50](默认今天): " Date
    if [ "${Date}" = "" ]; then
        # Date=$(date '+%Y-%m-%dT%H:%M:%S')
        Date=$(date '+%Y-%m-%d')
    fi
    Time="08:"$(rand 55 59)":"$(rand 10 59)
    DateTime=$Date"T"$Time
    echo -e "the datetime:[\033[32;1m${DateTime}\033[0m]"
    echo "Press any key to start to change the log...or Press Ctrl+C to cancel"
    char=`get_char`

    ./sqlite3_mips ZKDB.db "UPDATE ATT_LOG SET Verify_Time = '${DateTime}' WHERE ID = '${ID}';"
    echo -e "[\033[32;1mChange Sucessfuly\033[0m]"
    ./sqlite3_mips ZKDB.db "SELECT ID,User_PIN,Verify_Time FROM ATT_LOG WHERE ID = '${ID}';"
    ./sqlite3_mips ZKDB.db ".quit"
}

function Usage(){
    while [ $# != 0 ]
    do
        case $1 in
            "checkin" )
                check_in $2
                exit
            ;;

            "change" )
                change_log
                exit
            ;;

            * )
            echo "Bad option, please choose again"
            echo "Usage: 1. bash $0 checkin [ID]";
            echo "       2. bash $0 change ";
            exit
        esac
    done
    echo "Bad option, please choose again"
    echo "Usage: 1. bash $0 checkin [ID]";
    echo "       2. bash $0 change ";
}

Usage "$@"