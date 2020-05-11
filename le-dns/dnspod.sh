#!/bin/bash

CONFIG=$1
DOMAIN_FULL=$2
TXT_TOKEN=$3
HEADERS="User-Agent: le-dns/1.0.0 (me@linsir.org) "

if [ ! -f "$CONFIG" ];then
    echo "ERROR, CONFIG NOT EXIST."
    exit 1
fi 

. "$CONFIG"

SUB_DOMAIN=${DOMAIN_FULL%$DOMAIN}

if [ -z "$SUB_DOMAIN" ];then
    HOST="_acme-challenge"
else
    HOST="_acme-challenge.${SUB_DOMAIN%.}"
fi

OPTIONS="login_token=${TOKEN}";
OUT=$(curl -s -k "https://dnsapi.cn/Domain.List" -H "${HEADERS}" -d "${OPTIONS}&keyword=${DOMAIN}");
# echo $OUT
RES=$(echo $OUT | python get.py)

for line in $RES; do
    DOMAIN_ID=$(echo $line |awk -F ':' '{print $1}')
    DOMAIN_NAME=$(echo $line |awk -F ':' '{print $2}')
    if [ "$DOMAIN_NAME" = "$DOMAIN" ];then
        break;
    fi
done

echo "DOMAIN_NAME: $DOMAIN_NAME DOMAIN_ID: $DOMAIN_ID"

if [ "$DOMAIN_NAME" = "" ] || [ "$DOMAIN_ID" = "" ]; then
    echo "Can not get then DOMAIN_ID and DOMAIN_NAME, STOP NOW !!!"
    exit 1
fi

OUT=$(curl -s -k "https://dnsapi.cn/Record.List" -H "${HEADERS}" -d "${OPTIONS}&domain_id=${DOMAIN_ID}&record_type=TXT&sub_domain=$HOST")
# echo $OUT
RES=$(echo $OUT | python get.py)

for line in $RES; do
    RECORD_ID=$(echo $line |awk -F ':' '{print $1}')
    RECORD_NAME=$(echo $line |awk -F ':' '{print $2}')
    if [ "$DOMAIN_NAME" = "$HOST" ];then
        break;
    fi
done
echo "RECORD_NAME: $RECORD_NAME RECORD_ID: $RECORD_ID"

echo "POST data: ${OPTIONS}&domain_id=${DOMAIN_ID}&sub_domain=${HOST}&record_line=${RECORD_LINE}&record_type=TXT&value=${TXT_TOKEN}"
if [ "$RECORD_NAME" = "$HOST" ];then
    echo "UPDATE RECORD"
    OUT=$(curl -k -s "https://dnsapi.cn/Record.Modify" -H "${HEADERS}" -d "${OPTIONS}&domain_id=${DOMAIN_ID}&record_id=${RECORD_ID}&sub_domain=${HOST}&record_line=${RECORD_LINE}&record_type=TXT&value=${TXT_TOKEN}")
else
    echo "NEW RECORD"
    OUT=$(curl -k -s "https://dnsapi.cn/Record.Create" -H "${HEADERS}" -d "${OPTIONS}&domain_id=${DOMAIN_ID}&sub_domain=${HOST}&record_line=${RECORD_LINE}&record_type=TXT&value=${TXT_TOKEN}")
fi

if [ "$(echo "$OUT"|grep 'successful' -c)" != 0 ];then
    echo "DNS UPDATE SUCCESS"
else
    echo "DNS UPDATE FAILED"
fi
