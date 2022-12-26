FROM alpine AS Build-web

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

FROM python:3.10-alpine

ENV S6_SERVICES_GRACETIME=30000 \
    S6_KILL_GRACETIME=60000 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SYNC_DISKS=1 \
    TZ=Asia/Shanghai \
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    PS1="\u@\h:\w \$ " \
    CRON='0 0 * * *'

RUN apk add --no-cache \
    bash \
    su-exec \
    tzdata \
    s6-overlay && \
    python3 -m pip install linuxdir2html && \
    rm -rf /tmp/* /root/.cache /var/cache/apk/* && \
    mkdir -p /app

COPY --from=Build-web --chmod=755 /src/darkhttpd-static /app/darkhttpd
COPY --chmod=755 s6-overlay /

VOLUME [ "/out" ]
VOLUME [ "/Scan" ]

EXPOSE 4774

ENTRYPOINT ["/init"]
