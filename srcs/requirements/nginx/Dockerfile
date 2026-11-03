FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx openssl gettext-base \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default

COPY conf/inception.conf.template /etc/nginx/templates/inception.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["entrypoint.sh"]
# "daemon off" keeps nginx in the foreground as PID 1
CMD ["nginx", "-g", "daemon off;"]
