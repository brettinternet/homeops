FROM node:19-alpine

RUN apk add --no-cache dumb-init && \
    npm install -g zx@latest

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
