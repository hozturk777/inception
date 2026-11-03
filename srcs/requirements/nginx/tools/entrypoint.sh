#!/bin/sh
set -e

# Self-signed certificate, created at runtime so the key is not stored in the image
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=TR/ST=Istanbul/L=Istanbul/O=42/CN=${DOMAIN_NAME}"
fi

# Only ${DOMAIN_NAME} is substituted; nginx variables like $uri stay untouched
envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/inception.conf.template \
    > /etc/nginx/conf.d/inception.conf

# Replace the shell so nginx becomes PID 1 and receives signals
exec "$@"
