#!/bin/bash

IMAGE=nginx:alpine

docker pull ${IMAGE}
docker rm -f nginx
docker run --detach --restart always --name nginx \
	-p 80:80 \
	-v /mnt/storage/docker/nginx/static:/usr/share/nginx/html \
	-v /mnt/storage/docker/nginx/conf.d:/etc/nginx/conf.d \
	${IMAGE}

