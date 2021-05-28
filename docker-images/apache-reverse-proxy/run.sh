#!/bin/bash
docker run -d --name apache-static res/apache
docker run -d --name express-dynamic res/express
docker run -d -p 8080:80 res/proxy
