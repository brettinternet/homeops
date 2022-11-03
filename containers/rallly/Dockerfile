# https://github.com/lukevella/rallly/blob/main/Dockerfile
FROM node:alpine as build

RUN apk --update add git && \
    git clone https://github.com/lukevella/rallly /app

ARG DATABASE_URL
ENV DATABASE_URL $DATABASE_URL

ENV PORT 3000
ARG DATABASE_URL
ENV DATABASE_URL $DATABASE_URL

WORKDIR /app

RUN yarn --frozen-lockfile
RUN yarn build

EXPOSE 3000

ENTRYPOINT [ "/app/docker_start.sh" ]
