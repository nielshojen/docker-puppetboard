FROM python:3.6-alpine

ENV PUPPET_BOARD_VERSION="1.0.0" \
    GUNICORN_VERSION="19.7.1" \
    PUPPETBOARD_WEBPORT="8000" \
    PUPPETBOARD_SETTINGS="docker_settings.py"

RUN apk update && apk add nginx && adduser -D -g 'www' www && chown -R www:www /var/lib/nginx && pip install puppetboard=="$PUPPET_BOARD_VERSION" gunicorn=="$GUNICORN_VERSION"


EXPOSE $PUPPETBOARD_WEBPORT

WORKDIR /var/www/puppetboard

CMD gunicorn -b 0.0.0.0:${PUPPETBOARD_WEBPORT} --access-logfile=/dev/stdout puppetboard.app:app
# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --fail -X GET localhost:8000\
  |  grep -q 'Live from PuppetDB' \
  || exit 1
