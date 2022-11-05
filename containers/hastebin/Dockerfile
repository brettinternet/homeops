FROM node:16-stretch

RUN apt update && apt install git && \
    git clone https://github.com/toptal/haste-server /usr/src/app && \
    chown -R node:node /usr/src/app

USER node:node
WORKDIR /usr/src/app
RUN npm ci

# defaults
ENV STORAGE_EXPIRE_SECONDS=2592000
ENV LOGGING_LEVEL=verbose
ENV LOGGING_TYPE=Console
ENV LOGGING_COLORIZE=true
ENV HOST=0.0.0.0
ENV PORT=7777
ENV KEY_LENGTH=10
ENV MAX_LENGTH=400000
ENV STATIC_MAX_AGE=86400
ENV RECOMPRESS_STATIC_ASSETS=true
ENV KEYGENERATOR_TYPE=phonetic
ENV KEYGENERATOR_KEYSPACE=
ENV RATELIMITS_NORMAL_TOTAL_REQUESTS=500
ENV RATELIMITS_NORMAL_EVERY_MILLISECONDS=60000
ENV RATELIMITS_WHITELIST_TOTAL_REQUESTS=
ENV RATELIMITS_WHITELIST_EVERY_MILLISECONDS=
ENV RATELIMITS_WHITELIST=example1.whitelist,example2.whitelist
ENV RATELIMITS_BLACKLIST_TOTAL_REQUESTS=
ENV RATELIMITS_BLACKLIST_EVERY_MILLISECONDS=
ENV RATELIMITS_BLACKLIST=example1.blacklist,example2.blacklist

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
