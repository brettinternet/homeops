FROM alpine:latest

ARG TARGET_ARCH
ENV TARGET_ARCH=${TARGET_ARCH:-amd64}

RUN apk --update add python3 git smartmontools tzdata curl && \
    apk add snapraid --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted && \
    git clone https://github.com/Chronial/snapraid-runner.git /app/snapraid-runner && \
    chmod +x /app/snapraid-runner/snapraid-runner.py && \
    rm -rf /var/cache/apk/* && \
    curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGET_ARCH}/kubectl" && \
    chmod +x /usr/local/bin/kubectl

VOLUME /config

COPY /entrypoint.sh  /entrypoint.sh
RUN chmod 755 /entrypoint.sh

CMD ["/entrypoint.sh"]
