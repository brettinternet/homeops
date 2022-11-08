# https://wiki.alpinelinux.org/wiki/Cgit
FROM alpine:latest

ARG PUID=1000
ARG PGID=1000

RUN set -xe \
    apk add --no-cache --purge -uU \
      ca-certificates curl cgit openssh-server git highlight \
    fcgiwrap spawn-fcgi nginx envsubst dumb-init && \
    # python3 py-markdown py3-pygments markdown
    adduser -u ${PUID} -h /home/git -D -s /usr/bin/git-shell git users && \
    passwd -d -u git && \
    rm -rf /var/cache/apk/* /tmp/* && \
    mkdir /srv/git && \
    chown ${PUID}:${PGID} /srv/git

ENV ROOT_TITLE="Git" ROOT_DESC="My git repositories" SECTION_FROM_STARTPATH=0 MAX_REPO_COUNT=50
COPY cgitrc.template /etc/
COPY syntax-highlighting.sh /usr/lib/cgit/filters/
COPY default.conf /etc/nginx/sites-available/default
COPY 404.html /usr/share/nginx/html/
COPY 401.html /usr/share/nginx/html/
COPY start.sh /start.sh

# cache: /var/cache/cgit https://git.zx2c4.com/cgit/tree/cgitrc.5.txt
VOLUME /srv/git /var/cache/cgit
EXPOSE 80 22
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
