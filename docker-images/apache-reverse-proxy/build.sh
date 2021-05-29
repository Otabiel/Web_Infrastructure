#!/bin/bash
docker build -t res/apache_1 docker-images/apache-php-image/
docker build -t res/apache_2 docker-images/apache-php-image_bis/
docker build -t res/express docker-images/express-image/

docker build -t res/proxy docker-images/apache-reverse-proxy/
