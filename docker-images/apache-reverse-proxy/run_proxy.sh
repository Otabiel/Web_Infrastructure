#!/bin/bash
docker run -d -e STATIC_APP_01=$1:80 -e STATIC_APP_02=$2:80 -e DYNAMIC_APP_01=$3:3000 -e DYNAMIC_APP_02=$4:3000 -p 8080:80 --name apache-rp res/proxy

