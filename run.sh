#!/bin/sh

gunicorn -b 0.0.0.0:8000 puppetboard.app:app &

if [[ ${ADMIN_USER} ]] && [[ ${ADMIN_PASS} ]] && [[ ! ${OAUTH2_PROXY_COOKIE_SECRET} ]]; then
    /usr/bin/htpasswd -b -c /etc/nginx/htpasswd/puppetboard ${ADMIN_USER} ${ADMIN_PASS}
    /usr/sbin/nginx
    /usr/bin/tail -F /var/log/nginx/access.log
elif [[ -f "/etc/nginx/htpasswd/puppetboard" ]]
    /usr/sbin/nginx
    /usr/bin/tail -F /var/log/nginx/access.log
fi

if [[ -f "/etc/oauth2_proxy.cfg" ]]; then
    /usr/local/bin/oauth2_proxy
elif [[ ${OAUTH2_PROXY_COOKIE_SECRET} ]] && [[ ${OAUTH2_PROXY_EMAIL_DOMAINS} ]] && [[ ${OAUTH2_PROXY_CLIENT_SECRET} ]]; then
    /usr/local/bin/oauth2_proxy
fi