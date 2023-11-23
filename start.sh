#!/bin/bash

# Set custom webroot
if [ ! -z "$WEBROOT" ]; then
 sed -i "s#root /var/www/html;#root ${WEBROOT};#g" /etc/nginx/conf.d/default.conf
else
 webroot=/var/www/html
fi
if [ ! -z "$PHPFPMHOST" ]; then
 sed -i "s#fastcgi_pass php-fpm:9000#fastcgi_pass ${$PHPFPMHOST}:9000;#g" /etc/nginx/conf.d/default.conf
else
 webroot=/var/www/html
fi

# Enable custom nginx config files if they exist
if [ -f /var/www/html/conf/nginx.conf ]; then
  cp /var/www/html/conf/nginx.conf /etc/nginx/nginx.conf
fi

if [ -f /var/www/html/conf/nginx-site.conf ]; then
  cp /var/www/html/conf/nginx-site.conf /etc/nginx/conf.d/default.conf
fi

# Pass real-ip to logs when behind ELB, etc
if [[ "$REAL_IP_HEADER" == "1" ]] ; then
 sed -i "s/#real_ip_header X-Forwarded-For;/real_ip_header X-Forwarded-For;/" /etc/nginx/conf.d/default.conf
 sed -i "s/#set_real_ip_from/set_real_ip_from/" /etc/nginx/conf.d/default.conf
 if [ ! -z "$REAL_IP_FROM" ]; then
  sed -i "s#172.16.0.0/12#$REAL_IP_FROM#" /etc/nginx/conf.d/default.conf
 fi
fi

# Do the same for SSL sites
if [ -f /etc/nginx/conf.d/default-ssl.conf ]; then
 if [[ "$REAL_IP_HEADER" == "1" ]] ; then
  sed -i "s/#real_ip_header X-Forwarded-For;/real_ip_header X-Forwarded-For;/" /etc/nginx/conf.d/default-ssl.conf
  sed -i "s/#set_real_ip_from/set_real_ip_from/" /etc/nginx/conf.d/default-ssl.conf
  if [ ! -z "$REAL_IP_FROM" ]; then
   sed -i "s#172.16.0.0/12#$REAL_IP_FROM#" /etc/nginx/conf.d/default-ssl.conf
  fi
 fi
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
