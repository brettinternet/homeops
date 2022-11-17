FROM bash:alpine3.16

RUN apk --update add git curl jq dumb-init

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
