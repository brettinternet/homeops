# https://wiki.alpinelinux.org/wiki/Cgit
FROM alpine:latest

RUN set -xe && \
    apk add --no-cache --purge -uU \
    curl git cgit py3-pygments python3 py3-markdown markdown \
    fcgiwrap spawn-fcgi nginx gettext dumb-init && \
    rm -rf /var/cache/apk/* /tmp/* && \
    mkdir -p /srv/git

ENV ROOT_TITLE="Git" ROOT_DESC="My git repositories" SECTION_FROM_STARTPATH=0 MAX_REPO_COUNT=50 NOPLAINEMAIL=1
COPY --chown=nginx cgit.png /usr/share/webapps/cgit/
COPY --chown=nginx favicon.ico /usr/share/webapps/cgit/
COPY cgitrc.template /etc/
COPY nginx.conf /etc/nginx/
COPY start.sh /start.sh

VOLUME /var/lib/git /var/cache/cgit
EXPOSE 80
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
