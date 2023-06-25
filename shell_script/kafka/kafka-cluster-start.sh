#!/bin/bash

# Kafka server list (Kafka 서버 목록, 공백으로 구분)
KAFKA_SERVER_LIST="kafka1 kafka2 kafka3" 

# Kafka Owner (Kafka 서버를 실행할 Linux user)
KAFKA_OWNER="manager" 

# Kafka home directory (Kafka 설치 경로)
KAFKA_HOME="/home/manager/kafka" 

#################################################################################################

NO_COLOR='\033[0m'
RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
SIGNAL=${SIGNAL:-TERM}

# PID getter
pid_getter(){
        PIDS=$(ssh -o LogLevel=error $KAFKA_OWNER@$1 "ps ax | grep $KAFKA_HOME/bin | grep java | grep -v grep | awk '{print \$1}'")
        echo "${PIDS}" 
            }

if [ $# -ne 1 ];
then
        echo "USAGE: $0 [ start | stop | status ]" 
        exit 1
fi

if [ $1 = "start" ];
then
 for i in $KAFKA_SERVER_LIST
        do
                PIDS=$(pid_getter $i)
                if [ -z "$PIDS" ]; then
                        echo
                        echo "[$i] Kafka server is starting." 
                        START_RESULT=$(ssh -o LogLevel=error $KAFKA_OWNER@$i "$KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties")
                        sleep 1s
                        PRINT_PIDS=$(pid_getter $i)

                        if [ -z "$PRINT_PIDS" ]; then
                                echo -e "[$i] Kafka server startup ${RED_COLOR}failed.${NO_COLOR}" 
                        else
                                echo -e "[$i] Kafka server started ${GREEN_COLOR}successful.${NO_COLOR}" 
                                echo "[$i] Kafka server pid is $PRINT_PIDS" 
                        fi
                else
                        echo "[$i] Kafka server is already running." 
                fi
        done

# Kafka Stop
elif [ $1 = "stop" ];
then
        echo -e "[${RED_COLOR}Danger${NO_COLOR}] All servers will be shut down." 
      for i in $KAFKA_SERVER_LIST
      do
            PIDS=$(pid_getter $i)
               echo
           if [ -z "$PIDS" ]; then
                                echo "[$i] kafka server is not running." 
                  else
                                ssh -o LogLevel=error $KAFKA_OWNER@$i "kill -s $SIGNAL $PIDS" 
                                echo "[$i] Kafka server has been shut down." 
            fi
done
elif [ $1 = "status" ];
then
        for i in $KAFKA_SERVER_LIST
        do
                PIDS=$(pid_getter $i)
                echo

                if [ -z "$PIDS" ]; then
                        echo -e "[$i] Kafka server is ${RED_COLOR}stopped.${NO_COLOR}" 
                else
                        echo -e "[$i] Kafka server is ${GREEN_COLOR}running.${NO_COLOR}" 
                        echo -e "[$i] pid is $PIDS" 
                fi
        done

else
        echo "USAGE: $0 [ start | stop | status ]" 
        exit 1
fi
