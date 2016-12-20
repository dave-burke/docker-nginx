FROM nginx:stable-alpine
MAINTAINER dburke

# Install
RUN apk update && apk add certbot

# Static files
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/*

COPY robots.txt /usr/share/nginx/html/

# Utility scripts
COPY init.sh /usr/local/bin/

EXPOSE 80 443

CMD ["init.sh"]

