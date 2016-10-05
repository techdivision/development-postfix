FROM alpine:edge

MAINTAINER Vadim Justus <v.justus@techdivision.com>

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache --update \
        postfix \
        postfix-pcre \
        ca-certificates \
        supervisor \
        rsyslog \
        bash && \
    (rm "/tmp/"* 2>/dev/null || true) && (rm -rf /var/cache/apk/* 2>/dev/null || true)

COPY usr/bin/mailhog /usr/bin/mailhog
COPY etc /etc

RUN chmod +x /etc/postfix/start.sh && \
    chmod +x /usr/bin/mailhog

USER root

EXPOSE 587 1025 8025

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]