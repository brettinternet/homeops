FROM alpine:latest

RUN apk --update add python3 git smartmontools tzdata curl && \
    apk add snapraid --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted && \
    git clone https://github.com/Chronial/snapraid-runner.git /app/snapraid-runner && \
    chmod +x /app/snapraid-runner/snapraid-runner.py && \
    rm -rf /var/cache/apk/*

VOLUME /config

COPY /entrypoint.sh  /entrypoint.sh
RUN chmod 755 /entrypoint.sh

CMD ["/entrypoint.sh"]
