#!/bin/bash 

dir="/usr/share/nginx/html"
letsencrypt renew --non-interactive --agree-tos \
	--webroot --webroot-path "${dir}"

