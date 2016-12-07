#!/bin/sh

write_config() {
	local subdomain="${1}"
	local backend="${2}"
	cat >> /etc/nginx/conf.d/"${subdomain}".conf <<-EOF
	server {
		listen 80;
		server_name ${subdomain}.${HOSTNAME};
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

cat > /etc/nginx/conf.d/default.conf <<-EOF
server {
	listen 80;
	server_name ${HOSTNAME};

	location / {
		root /usr/share/nginx/html;
		try_files \$uri \$uri/ =404;
		autoindex on;
	}

}
EOF

cd "$(dirname ${0})"

while read line; do
	write_config $line
done < /etc/nginx/proxy-config.cfg

nginx -g "daemon off;"

