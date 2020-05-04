FROM python:3.8-alpine

ENV PUPPET_BOARD_VERSION="2.1.1"
ENV GUNICORN_VERSION="20.0.0"
ENV PUPPETBOARD_WEBPORT="8000"
ENV PUPPETBOARD_SETTINGS="docker_settings.py"

RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app/

RUN apk update && \
    apk add nginx && \
    apk --update --no-cache add libc-dev binutils && \
    adduser -D -g 'www' www && chown -R www:www /var/lib/nginx && \
    mkdir /run/nginx && \
    mkdir /etc/nginx/htpasswd && \
    apk add apache2-utils && \
    wget -P /tmp https://github.com/pusher/oauth2_proxy/releases/download/v4.0.0/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    tar -C /tmp -zxvf /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    rm /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    mv /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1/oauth2_proxy /usr/local/bin/oauth2_proxy && \
    rm -rf /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1

COPY requirements*.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements-docker.txt

ADD nginx.conf /etc/nginx.nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf
ADD puppetboard.conf /etc/nginx/conf.d/puppetboard.conf
ADD run.sh /

RUN chmod +x /run.sh

EXPOSE 80
EXPOSE 443
EXPOSE 4180
EXPOSE 8000

WORKDIR /var/www/puppetboard

CMD /run.sh

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --fail -X GET localhost:8000\
  |  grep -q 'Live from PuppetDB' \
  || exit 1
