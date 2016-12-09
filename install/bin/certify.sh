#!/bin/bash

set -e

dir="/usr/share/nginx/html"
domain="${1}"
if [[ -z "${domain}" ]]; then
	echo "Domain is required"
	exit 1
fi
email="${2}"
if [[ -z "${email}" ]]; then
	echo "Email is required"
	exit 1
fi

echo "Requesting certificate for ${domain} on behalf of ${email}"

letsencrypt certonly --non-interactive --agree-tos \
	--webroot --webroot-path "${dir}" \
	--domain "${domain}" \
	--email "${email}"

