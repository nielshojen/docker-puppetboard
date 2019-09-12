FROM python:3.6-alpine

ENV PUPPET_BOARD_VERSION="1.0.0"
ENV GUNICORN_VERSION="19.7.1"
ENV PUPPETBOARD_WEBPORT="8000"
ENV PUPPETBOARD_SETTINGS="docker_settings.py"

RUN apk update && \
    apk add nginx && \
    adduser -D -g 'www' www && chown -R www:www /var/lib/nginx && \
    mkdir /run/nginx && \
    mkdir /etc/nginx/htpasswd && \
    apk add apache2-utils && \
    wget -P /tmp https://github.com/pusher/oauth2_proxy/releases/download/v4.0.0/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    tar -C /tmp -zxvf /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    rm /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    mv /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1/oauth2_proxy /usr/local/bin/oauth2_proxy && \
    rm -rf /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1 && \
    pip install puppetboard=="$PUPPET_BOARD_VERSION" gunicorn=="$GUNICORN_VERSION"

ADD nginx.conf /etc/nginx.nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf
ADD puppetboard.conf /etc/nginx/conf.d/puppetboard.conf
ADD run.sh /

RUN chmod +x /run.sh

EXPOSE 80
EXPOSE 443
EXPOSE 8000

WORKDIR /var/www/puppetboard

CMD /run.sh

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --fail -X GET localhost:8000\
  |  grep -q 'Live from PuppetDB' \
  || exit 1
