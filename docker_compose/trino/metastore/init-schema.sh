#!/bin/bash

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
sleep 10

echo "Initializing Hive Metastore schema..."

/opt/hive-metastore/bin/schematool -dbType mysql -initSchema -userName hive -passWord hive -url jdbc:mysql://mysql:3306/metastore_db

echo "Hive Metastore initialization completed"
