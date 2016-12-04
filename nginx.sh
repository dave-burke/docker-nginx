#!/bin/bash

IMAGE=nginx:alpine
NAME=nginx-proxy

here="$(cd $(dirname ${0}); pwd)"

docker pull "${IMAGE}"
docker rm -f "${NAME}"
docker run \
	--name "${NAME}" \
	--restart always \
	-p 80:80 \
	-v "${here}/install":"/opt/${NAME}/":ro \
	${IMAGE} \
	"/opt/${NAME}/init.sh"

