#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters" 
    exit 1
fi

CONFIG_FILE=$HOME/kafka-zk/conf/zoo.cfg

# dataDir
sed -i "s/dataDir=\/tmp\/zookeeper/dataDir=\/home\/manager\/kafka-zk\/zookeeper-data/" $CONFIG_FILE

# clientPort
sed -i "s/clientPort=2181/clientPort=12181/" $CONFIG_FILE

# server
i=1
for var in "$@" 
do
    echo "server.${i}=${var}:12888:13888" >> $CONFIG_FILE
    ((i=i+1))
done

echo "admin.enableServer=false" >> $CONFIG_FILE
