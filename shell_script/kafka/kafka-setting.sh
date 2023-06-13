#!/bin/bash

# help print
function print_help() {
/bin/cat << EOF

Usage :
    $0 [-i value] [-a value] [-l value] [-z value]
Required Option :
    -i,  Broker ID (int)
    -a,  Broker Server IP Address
    -l,  kafka log directory path
    -z,  zookeeper connect address (ex. 0.0.0.0:2181,0.0.0.1:2181,0.0.0.2:2181)
Option :
    -m,  message byte (int, default 157286400)
EOF
}

# check arguments
if [ $# -eq 0 ]; then
    print_help
    exit 1
fi

# set option default
MESSAGE_BYTE=157286400

# process arguments
while getopts "i:a:l:z:m:" opt
do
    case $opt in
        i)
            BROKER_ID=$OPTARG
            ;;
        a)
            BROKER_IP=$OPTARG
            ;;
        l)
            LOG_DIR=$OPTARG
            ;;
        z)
            ZOOKEEPER_IPS=$OPTARG
            ;;
        m)
            MESSAGE_BYTE=$OPTARG
            ;;
        ?) #에러에 대한 옵션이다
            echo "Invalid Arguments, Raise Error" 
            print_help
            exit 1
            ;;
    esac
done

# check required arguments
if [ -z "$BROKER_ID" ] || [ -z "$BROKER_IP" ] || [ -z "$LOG_DIR" ] || [ -z "$ZOOKEEPER_IPS" ]; then
    echo "Required arguments Not exists" 
    print_help
    exit 1
fi

# print
echo "broker.id=$BROKER_ID" 
echo "listeners=PLAINTEXT://$BROKER_IP:9092" 
echo "log.dirs=$LOG_DIR" 
echo "zookeeper.connect=$ZOOKEEPER_IPS" 
echo "message.max.bytes=$MESSAGE_BYTE" 

CONFIG_FILE=server.properties

# broker.id
sed -i "s/broker.id=0/broker.id=$BROKER_ID/" $CONFIG_FILE

# listeners
sed -i "s/^#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/$BROKER_IP:9092/" $CONFIG_FILE

# log.dirs
sed -i "s%log.dirs=/tmp/kafka-logs%log.dirs=$LOG_DIR%" $CONFIG_FILE

# zookeeper.connect
sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=$ZOOKEEPER_IPS/" $CONFIG_FILE

# default 추가
cat << EOF >> $CONFIG_FILE

# ADD Custom Config
api.version.request=false
auto.commit.enable=false
delete.topic.enable=true
auto.create.topics.enable=false
message.max.bytes=$MESSAGE_BYTE
EOF
