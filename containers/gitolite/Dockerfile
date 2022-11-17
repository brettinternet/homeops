FROM alpine:latest

RUN set -xe && \
    apk add --no-cache --purge -uU \
    git gitolite openssh dumb-init && \
    rm -rf /var/cache/apk/* /tmp/*

VOLUME /var/lib/git /etc/ssh/keys
EXPOSE 22
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
COPY start.sh /start.sh
CMD ["/start.sh"]
