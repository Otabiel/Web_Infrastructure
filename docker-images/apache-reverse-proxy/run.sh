#!/bin/bash
docker run -d --name apache-static res/apache
docker run -d --name express-dynamic res/express
docker run -d -e STATIC_APP=$1:80 -e DYNAMIC_APP=$2:3000 -p 8080:80 --name apache-rp res/proxy

