FROM alpine:latest

RUN apk --update add python3 git smartmontools tzdata curl dumb-init && \
    apk add snapraid --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted && \
    git clone https://github.com/Chronial/snapraid-runner.git /app/snapraid-runner && \
    chmod +x /app/snapraid-runner/snapraid-runner.py && \
    rm -rf /var/cache/apk/*

VOLUME /config

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
COPY start.sh  /start.sh
RUN chmod 755 /start.sh
CMD ["/start.sh"]
