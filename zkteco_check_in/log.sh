#!/bin/bash
# @Date    : 2016-06-07 16:04:54
# @Author  : Linsir (root@linsir.org)
# @Link    : http://linsir.org
# @Version : 0.2
# Last Update: 2016-12-07
# 2008 2010 2055

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#====================== log ======================

RED='\033[31m'   # 红
GREEN='\033[32m' # 绿
YELLOW='\033[33m' # 黄
BLUE='\033[34m'  # 蓝
PINK='\033[35m'  # 粉红
ADD='\033[0m'

function log_info() {
    NOW=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${NOW}${BLUE} [INFO] ${ADD} $1"
}

function log_warnning() {
    NOW=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${NOW}${YELLOW} [WARNNING] ${ADD} $1"
    echo -e "${NOW} [WARNNING] $1"
}

function log_error() {
    NOW=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${NOW}${RED} [ERROR] ${ADD} $1"
}

function log_line() {
    echo "#############################################################"
}

# 随机生成范围的数字
function rand(){
    local beg=$1
    local end=$2
    echo $((RANDOM % ($end - $beg) + $beg))
}

function del_log(){
    # Useage:
    # del_log [log_id]
    log_id=$1
    log_line
    old_time=`./sqlite3_mips ZKDB.db "SELECT Verify_Time FROM ATT_LOG WHERE ID = '${log_id}';"`
    user_id=`./sqlite3_mips ZKDB.db "SELECT User_PIN FROM ATT_LOG WHERE ID = '${log_id}';"`
    if [ "${user_id}" = "" ]; then
        log_error "Bad [${RED}log_id${ADD}], please try again"
        menu
        exit
    fi
    name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${user_id}'"`
    echo -e "Are you sure delete the log: [${GREEN}${name}: ${old_time}${ADD}] "
    read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'
    ./sqlite3_mips ZKDB.db "DELETE FROM ATT_LOG WHERE ID = '${log_id}'"
    echo -e "[${GREEN}Delete Sucessfuly${ADD}]"
    ./sqlite3_mips ZKDB.db ".quit"
}

function query_id(){
    # Useage:
    # query_id [name]
    name=$1
    log_line
    user_id=`./sqlite3_mips ZKDB.db "SELECT User_PIN FROM USER_INFO WHERE NAME = '${name}'"`
    if [ "${user_id}" = "" ]; then
        log_error "Bad [${RED}name${ADD}], please try again"
        menu
        exit
    fi
    echo -e "[${GREEN}${name}${ADD}]'s ID is [${GREEN}${user_id}${ADD}] "
    ./sqlite3_mips ZKDB.db ".quit"
}

function check_in(){
    # Useage:
    # check_in [user_id]
    user_id=$1
    log_line
    name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${user_id}'"`
    if [ "${name}" = "" ]; then
        log_error "Bad [${RED}user_id${ADD}], please try again"
        menu
        exit
    fi

    today=$(date '+%Y-%m-%d')

    new_time="08:"$(rand 55 59)":"$(rand 10 59)
    DateTime=$today"T"$new_time

    # log_info "签到用户: [${GREEN}${name}${ADD}]"
    # log_info "the datetime:[${GREEN}${DateTime}${ADD}]"
    # read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'

    ./sqlite3_mips ZKDB.db "INSERT INTO ATT_LOG VALUES (null,'${user_id}',15,'${DateTime}','0','0',null,null,null,null,0);"
    save_time=`./sqlite3_mips ZKDB.db "SELECT Verify_Time FROM ATT_LOG WHERE User_PIN = '${user_id}' ORDER BY ID DESC LIMIT 0,1;"`
    log_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM ATT_LOG WHERE User_PIN = '${user_id}' ORDER BY ID DESC LIMIT 0,1;"`
    log_info "LOG_ID: ${GREEN}${log_id}: [${name}${ADD}] 签到时间: [${GREEN}${save_time}${ADD}] Sucessfuly."
    ./sqlite3_mips ZKDB.db ".quit"
}

function check_out(){
    # Useage:
    # check_out [user_id]
    log_line
    user_id=$1
    name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${user_id}'"`
    if [ "${name}" = "" ]; then
        log_error "Bad [${RED}user_id${ADD}], please try again"
        menu
        exit
    fi

    today=$(date '+%Y-%m-%d')

    new_time="17:"$(rand 35 59)":"$(rand 10 59)
    DateTime=$today"T"$new_time

    # log_info "签退用户: [${GREEN}${name}${ADD}]"
    # log_info "the datetime:[${GREEN}${DateTime}${ADD}]"
    # read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'

    # echo "签到时间: ${DateTime}"
    ./sqlite3_mips ZKDB.db "INSERT INTO ATT_LOG VALUES (null,'${user_id}',15,'${DateTime}','0','0',null,null,null,null,0);"
    save_time=`./sqlite3_mips ZKDB.db "SELECT Verify_Time FROM ATT_LOG WHERE User_PIN = '${user_id}' ORDER BY ID DESC LIMIT 0,1;"`
    log_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM ATT_LOG WHERE User_PIN = '${user_id}' ORDER BY ID DESC LIMIT 0,1;"`
    log_info "LOG_ID: ${GREEN}${log_id}: [${name}${ADD}] 签退时间: [${GREEN}${save_time}${ADD}] Sucessfuly."
    ./sqlite3_mips ZKDB.db ".quit"
}

function change_log(){
    log_line

    read -p "请输入签到用户工号(默认用户ID 2055): " user_id
    if [ "${user_id}" = "" ]; then
        user_id=2055
    fi
    name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${user_id}'"`
    if [ "${name}" = "" ]; then
        log_error "Bad [${RED}user_id${ADD}], please try again"
        menu
        exit
    fi
    log_info "签到用户: [${GREEN}${name}${ADD}] (${user_id})"
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
    if [ "${old_time}" = "" ]; then
        log_error "Bad [${RED}log_id${ADD}], please try again"
        menu
        exit
    fi
    echo -e "Are you sure to change [${GREEN}${old_time}${ADD}] into [${GREEN}${DateTime}${ADD}]?"
    read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'

    ./sqlite3_mips ZKDB.db "UPDATE ATT_LOG SET Verify_Time = '${DateTime}' WHERE ID = '${ID}';"
    echo -e "[${GREEN}Change Sucessfuly${ADD}]"
    # ./sqlite3_mips ZKDB.db "SELECT ID,User_PIN,Verify_Time FROM ATT_LOG WHERE ID = '${ID}';"
    ./sqlite3_mips ZKDB.db ".quit"
}

function change_finger(){
    # Useage:
    # check_out [old_user_id] help [new_user_id]
    log_line
    old_user_id=$1
    new_user_id=$2
    finger=$3
    if [ "${old_user_id}" = "" -a "${new_user_id}" = "" ]; then
        log_error "Bad option, please choose again"
        menu
        exit
    fi
    old_name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${old_user_id}'"`
    new_name=`./sqlite3_mips ZKDB.db "SELECT Name FROM USER_INFO WHERE User_PIN = '${new_user_id}'"`
    if [ "${old_name}" = "" -a "${new_name}" = "" ]; then
        log_error "Bad [${RED}ID${ADD}], please try again"
        menu
        exit
    fi
    old_user_defaulf_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM USER_INFO WHERE User_PIN = '${old_user_id}'"`
    new_user_defaulf_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM USER_INFO WHERE User_PIN = '${new_user_id}'"`

    if [ "$3" = "" ]; then
        finger_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM fptemplate10 WHERE pin = '${old_user_defaulf_id}' limit 1"`
    else
        finger_id=`./sqlite3_mips ZKDB.db "SELECT ID FROM fptemplate10 WHERE pin = '${old_user_defaulf_id}' and fingerid = '${finger}' "`
    fi
    if [ "${finger_id}" = "" ]; then

        log_error "the user [${GREEN}${old_name}${ADD}] have no finger data, please try again"
        menu
        exit
    fi
    finger_type=`./sqlite3_mips ZKDB.db "SELECT fingerid FROM fptemplate10 WHERE ID = '${finger_id}'"`
    log_info "用户: [${GREEN}${old_name}${ADD}] => [${GREEN}${new_name}${ADD}] fingerid([${GREEN}${finger_type}${ADD}])"
    read -rsp $'Press enter to continue...or Press Ctrl+C to cancel\n'
    ./sqlite3_mips ZKDB.db "UPDATE fptemplate10 SET pin = '${new_user_defaulf_id}', fingerid = '1' WHERE ID = '${finger_id}';"
    log_info "[${GREEN}Change Sucessfuly${ADD}]"
    ./sqlite3_mips ZKDB.db ".quit"

}
function menu(){
    log_line
    echo "# @Author  : Linsir (root@linsir.org)"
    echo "# @Link    : http://linsir.org"
    echo "# @Version : 0.3"
    echo -e "Bad option, please choose again"
    echo -e "Usage: 1. bash $0 query name: Query [${GREEN}name${ADD}]'s user_id."
    echo -e "       2. bash $0 checkin user_id: Check in for [${GREEN}user_id${ADD}]'s user."
    echo -e "       3. bash $0 checkout user_id: Check out for [${GREEN}user_id${ADD}]'s user."
    echo -e "       4. bash $0 change: Change checkin time of current month."
    echo -e "       5. bash $0 change time (2016-06-06T16:03:50): Change checkin [${GREEN}time${ADD}] of current month with time."
    echo -e "       6. bash $0 del log_id: Delete the [${GREEN}log_id${ADD}]'s checkin log."
    echo -e "       7. bash $0 help ID1 ID2 [fingerid]: Use [${GREEN}ID1${ADD}] 's finger([${GREEN}fingerid${ADD}]) help [${GREEN}ID2${ADD}] to checkin.' "
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
            "checkout" )
                check_out $2
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
                change_finger $2 $3 $4
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
