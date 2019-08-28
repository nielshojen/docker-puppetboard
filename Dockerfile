FROM python:3.6-alpine

ENV PUPPET_BOARD_VERSION="1.0.0"
ENV GUNICORN_VERSION="19.7.1"
ENV PUPPETBOARD_WEBPORT="8000"
ENV PUPPETBOARD_SETTINGS="docker_settings.py"

RUN apk update && \
    apk add nginx && \
    adduser -D -g 'www' www && chown -R www:www /var/lib/nginx && \
    mkdir /run/nginx && \
    pip install puppetboard=="$PUPPET_BOARD_VERSION" gunicorn=="$GUNICORN_VERSION"

EXPOSE 80
EXPOSE $PUPPETBOARD_WEBPORT

WORKDIR /var/www/puppetboard

CMD gunicorn -b 0.0.0.0:${PUPPETBOARD_WEBPORT} puppetboard.app:app
CMD /usr/sbin/nginx

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --fail -X GET localhost:8000\
  |  grep -q 'Live from PuppetDB' \
  || exit 1
