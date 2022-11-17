FROM bash:alpine3.16

RUN apk --update add git curl jq dumb-init

COPY entrypoint.sh  /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
