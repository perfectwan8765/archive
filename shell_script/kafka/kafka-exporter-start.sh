#/bin/bash

KAFKA_IP=127.0.0.1
KAFKA_PORT=9092
EXPORTER_PORT=9101

nohup ./kafka_exporter --kafka.server=$KAFKA_IP:$KAFKA_PORT --web.listen-address=":$EXPORTER_PORT"  > /dev/null 2>&1 &
