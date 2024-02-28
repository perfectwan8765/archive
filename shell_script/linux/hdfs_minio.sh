#!/bin/bash

d="2024-02-01"

until [[ $d > 2024-02-28 ]]; do
  dt=$(date -d "$d" +"%Y%m%d")
  BASIC_PATH="/test/dt=$dt"
  S3_PATH="connection-id/bucket-name/test/dt=$dt"
  if [ -d "$BASIC_PATH" ]; then
    mc mirror $BASIC_PATH $S3_PATH
  fi
  # hdfs dfs -ls -copyToLocal test/dt=$dt .
  d=$(date -I -d "$d + 1 day")
done
