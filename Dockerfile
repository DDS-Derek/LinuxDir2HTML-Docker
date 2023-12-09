FROM alpine:3.19 AS Build-web

ENV DARKHTTPD_TAG=v1.14
RUN apk add --no-cache build-base
WORKDIR /src
RUN wget \
        https://github.com/emikulic/darkhttpd/archive/refs/tags/${DARKHTTPD_TAG}.tar.gz \
        -O /tmp/darkhttpd.tar.gz \
    && \
    tar \
        -zxvf /tmp/darkhttpd.tar.gz \
        -C /src \
        --strip-components 1
RUN make darkhttpd-static \
 && strip darkhttpd-static

FROM python:3.12-alpine AS Build-app

RUN apk add --no-cache git binutils clang gcc build-base g++ zlib-dev
RUN pip install --upgrade pip
RUN pip install pyinstaller
WORKDIR /build
RUN git clone https://github.com/homeisfar/LinuxDir2HTML.git /build
WORKDIR /build/linuxdir2html
COPY build/* .
RUN pyinstaller LinuxDir2HTML.spec

FROM alpine:3.19 AS app

RUN apk add --no-cache \
    bash \
    tzdata \
    netcat-openbsd \
    s6-overlay && \
    rm -rf /tmp/* /root/.cache /var/cache/apk/*

COPY --from=Build-web --chmod=+x /src/darkhttpd-static /usr/bin/darkhttpd
COPY --from=Build-app --chmod=+x /build/linuxdir2html/dist/LinuxDir2HTML /usr/bin/linuxdir2html
COPY --chmod=755 ./rootfs /

FROM scratch

ENV S6_SERVICES_GRACETIME=30000 \
    S6_KILL_GRACETIME=60000 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SYNC_DISKS=1 \
    TZ=Asia/Shanghai \
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    CRON='0 0 * * *' \
    SCAN_DIR_OUT="/Scan:/out/html/index" \
    HTML_SAVE_TIME=7

COPY --from=app / /

ENTRYPOINT ["/init"]

VOLUME [ "/out" ]

EXPOSE 4774