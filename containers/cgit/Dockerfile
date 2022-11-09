# https://wiki.alpinelinux.org/wiki/Cgit
FROM alpine:latest

RUN set -xe && \
    apk add --no-cache --purge -uU \
    ca-certificates curl cgit openssh git highlight python3 py-markdown \
    fcgiwrap spawn-fcgi nginx gettext dumb-init && \
    rm -rf /var/cache/apk/* /tmp/* && \
    mkdir /srv/git

ENV ROOT_TITLE="Git" ROOT_DESC="My git repositories" SECTION_FROM_STARTPATH=0 MAX_REPO_COUNT=50
COPY --chown=nginx cgit.png /usr/share/webapps/cgit/
COPY --chown=nginx favicon.ico /usr/share/webapps/cgit/
COPY cgitrc.template /etc/
COPY nginx.conf /etc/nginx/
COPY syntax-highlighting.sh /usr/lib/cgit/filters/
COPY start.sh /start.sh

VOLUME /srv/git /var/cache/cgit
EXPOSE 80 22
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
