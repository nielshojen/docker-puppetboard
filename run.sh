#!/bin/sh

gunicorn -b 0.0.0.0:${PUPPETBOARD_WEBPORT} puppetboard.app:app &

/usr/bin/htpasswd -b -c /etc/nginx/htpasswd/puppetboard ${ADMIN_USER} ${ADMIN_PASS}

/usr/sbin/nginx

sleep infinity