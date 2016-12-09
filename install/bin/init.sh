#!/bin/sh

write_default() {
	local outfile=/etc/nginx/conf.d/default.conf

	cat >> "${outfile}" <<-EOF
	server {
		listen 80 default_server;
		server_name ${HOSTNAME};

		#include /opt/https_import.conf;

		location / {
			root /usr/share/nginx/html;
			try_files \$uri \$uri/ =404;
			autoindex off;
		}

	}
	EOF
}

write_proxy () {
	local subdomain="${1}"
	local backend="${2}"
	local outfile="/etc/nginx/conf.d/"${subdomain}".conf"

	cat >> "${outfile}" <<-EOF
	server {
		listen 80;
		server_name ${subdomain}.${HOSTNAME};

		#include /opt/https_import.conf;

		location / {
			proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
			proxy_set_header X-Forwarded-Host \$host;
			proxy_set_header X-Forwarded-Server \$host;
			proxy_set_header X-Forwarded-Proto http;
			proxy_pass ${backend};
			proxy_set_header Host \$host;
		}
	}
	EOF
}

cd "$(dirname ${0})"

write_default "${listen}"
while read line; do
	write_proxy $line "${listen}"
done < /etc/nginx/proxy-config.cfg

if [[ -n "${CERT_EMAIL}" ]]; then
	sed -i "s/listen 80/listen 443 ssl/" /etc/nginx/conf.d/*
	sed -i "s/#include/include/" /etc/nginx/conf.d/*
fi

nginx -g "daemon off;"

