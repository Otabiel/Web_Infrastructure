#!/bin/bash
docker run -d --name apache-static-1 res/apache_1
docker run -d --name apache-static-2 res/apache_2
docker run -d --name express-dynamic-1 res/express
docker run -d --name express-dynamic-2 res/express

