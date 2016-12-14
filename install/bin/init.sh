#!/bin/sh

set -e

CERTIFY_ARGS=""

add_subdomain() {
	local subdomain="${1}"
	local backend="${2}"
	local full_domain="${subdomain}.${ROOT_DOMAIN}"

	if [[ -n "${CERT_EMAIL}" ]]; then
		local listen="443 ssl"
		local https_config=$(cat <<-EOF
			ssl_certificate /etc/letsencrypt/live/${full_domain}/fullchain.pem;
			ssl_certificate_key /etc/letsencrypt/live/${full_domain}/privkey.pem;
			ssl_trusted_certificate /etc/letsencrypt/live/${full_domain}/chain.pem;

			ssl_session_timeout 1d;
			ssl_session_cache shared:SSL:50m;
			ssl_session_tickets off;

			# modern configuration from https://mozilla.github.io/server-side-tls/ssl-config-generator/
			ssl_protocols TLSv1.2;
			ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
			ssl_prefer_server_ciphers on;
		EOF
		)
	else
		local listen="80"
	fi

	cat > "/etc/nginx/conf.d/${subdomain}.conf" <<-EOF
	server {
		listen $listen;
		server_name ${full_domain};

		$https_config

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
	CERTIFY_ARGS="$CERTIFY_DOMAINS --domain ${full_domain} "
}
certify() {
	if [[ -n "${CERT_EMAIL}" && ! -f /etc/letsencrypt/live/${ROOT_DOMAIN}/fullchain.pem ]]; then
		# Get certificate
		set -x
		letsencrypt certonly --non-interactive --agree-tos \
			--standalone \
			--expand \
			$@ \
			--email "${CERT_EMAIL}"
		set +x
	fi
}

cd "$(dirname ${0})"

while read line; do
	add_subdomain $line
done < /etc/nginx/proxy-config.cfg
certify $CERTIFY_ARGS

nginx -g "daemon off;"

