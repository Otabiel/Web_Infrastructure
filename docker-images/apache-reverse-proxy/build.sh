#!/bin/bash
docker build -t res/apache docker-images/apache-php-image/
docker build -t res/express docker-images/express-image/

docker build -t res/proxy docker-images/apache-reverse-proxy/
