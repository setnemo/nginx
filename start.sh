#!/bin/sh

# Set custom webroot
if [ ! -z "$WEBROOT" ]; then
    sed -i "s#root /var/www/html;#root ${WEBROOT};#g" /etc/nginx/conf.d/default.conf
else
    webroot=/var/www/html
fi

if [ ! -z "$PHPFPMHOST" ]; then
    sed -i "s#fastcgi_pass php-fpm:9000;#fastcgi_pass ${PHPFPMHOST}:9000;#g" /etc/nginx/conf.d/default.conf
else
    webroot=/var/www/html
fi

# Run custom scripts
if [[ "$RUN_SCRIPTS" == "1" ]] ; then
    if [ -d "/var/www/html/scripts/" ]; then
        # make scripts executable incase they aren't
        chmod -Rf 750 /var/www/html/scripts/*; sync;
        # run scripts in number order
        for i in `ls /var/www/html/scripts/`; do /var/www/html/scripts/$i ; done
    else
        echo "Can't find script directory"
    fi
fi

# cp -Rf /var/www/html/config.orig/* /var/www/html/config/

if [[ "$CREATE_LARAVEL_STORAGE" == "1" ]] ; then
    mkdir -p /var/www/html/storage/{logs,app/public,framework/{cache/data,sessions,testing,views}}
    chown -Rf nginx.nginx /var/www/html/storage
    adduser -s /bin/bash -g 82 -D sail
fi

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
