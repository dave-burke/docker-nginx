#!/bin/bash

set -e

host="${1}"
email="${2}"

usage() {
	echo "$(basename ${0}) [domain] [optional: email]"
}

[[ -n "${host}" ]] || { usage; exit 1; }
if [[ -n "${email}" ]]; then
	httpsArgs=" --publish 443:443 --env CERT_EMAIL=${email} "
fi

image="dburke/nginx-proxy"
name="nginx-proxy"
data_name="nginx-data"

docker build --pull --tag "${image}" $(dirname $0)

data_cid="$(docker ps --all --quiet --filter=name=${data_name})"
if [ -z "${data_cid}" ]; then
	echo "Creating data container..."
	docker create \
		--volume /etc/letsencrypt \
		--name "${data_name}" ${image}
else
	echo "Using existing data container."
fi

cid="$(docker ps -q --filter=name=${name})"
if [ -n "${cid}" ]; then
	echo "Stopping container..."
	docker stop "${name}" > /dev/null
fi
cid="$(docker ps -q -a --filter=name=${name})"
if [ -n "${cid}" ]; then
	echo "Removing container..."
	docker rm "${name}" > /dev/null
fi

echo "Running container..."
set -x
docker run --detach --name ${name} \
	--restart always \
	--volume $(cd $(dirname ${0}); pwd)/config.cfg:/etc/nginx/proxy-config.cfg:ro \
	--volumes-from "${data_name}" \
	--publish 80:80 \
	$httpsArgs \
	--env ROOT_DOMAIN="${host}" \
	${image}
set +x

