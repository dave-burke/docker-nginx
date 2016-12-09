FROM nginx:stable-alpine
MAINTAINER dburke

# Install
RUN apk update && apk add certbot

# Static files
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/*

# Utility scripts
COPY ./install/bin/* /usr/local/bin/

COPY ./install/conf/https_import.conf /opt/https_import.conf

EXPOSE 80 443

CMD ["init.sh"]

