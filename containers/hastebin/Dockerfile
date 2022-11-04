FROM node:16-stretch

RUN apt update && apt install git && \
    git clone https://github.com/toptal/haste-server /usr/src/app && \
    chown node:node /usr/src/app

USER node:node

WORKDIR /usr/src/app

COPY --chown=node:node . .

RUN npm ci

# defaults
ENV STORAGE_EXPIRE_SECONDS=2592000 \
    LOGGING_LEVEL=verbose \
    LOGGING_TYPE=Console \
    LOGGING_COLORIZE=true \
    HOST=0.0.0.0 \
    PORT=7777 \
    KEY_LENGTH=10 \
    MAX_LENGTH=400000 \
    STATIC_MAX_AGE=86400 \
    RECOMPRESS_STATIC_ASSETS=true \
    KEYGENERATOR_TYPE=phonetic \
    KEYGENERATOR_KEYSPACE= \
    RATELIMITS_NORMAL_TOTAL_REQUESTS=500 \
    RATELIMITS_NORMAL_EVERY_MILLISECONDS=60000 \
    RATELIMITS_WHITELIST_TOTAL_REQUESTS= \
    RATELIMITS_WHITELIST_EVERY_MILLISECONDS= \
    RATELIMITS_WHITELIST=example1.whitelist,example2.whitelist \
    RATELIMITS_BLACKLIST_TOTAL_REQUESTS= \
    RATELIMITS_BLACKLIST_EVERY_MILLISECONDS= \
    RATELIMITS_BLACKLIST=example1.blacklist,example2.blacklist

EXPOSE ${PORT}
STOPSIGNAL SIGINT
ENTRYPOINT [ "bash", "docker-entrypoint.sh" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s \
    --retries=3 CMD [ "sh", "-c", "echo -n 'curl localhost:7777... '; \
    (\
        curl -sf localhost:7777 > /dev/null\
    ) && echo OK || (\
        echo Fail && exit 2\
    )"]
CMD ["npm", "start"]
