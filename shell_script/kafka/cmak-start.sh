#!/bin/bash

CMAK_PORT=58080

nohup $HOME/cmak/bin/cmak -Dconfig.file=$HOME/cmak/conf/application.conf -Dhttp.port=$CMAK_PORT 2>&1 &
