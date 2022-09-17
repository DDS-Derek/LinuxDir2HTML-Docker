FROM alpine:3.16

ENV TZ=Asia/Shanghai \
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    CRON='0 0 * * *'

RUN apk add --update --no-cache \
    python3-dev \
    py3-pip \
    bash \
    su-exec \
    tzdata && \
    python3 -m pip install linuxdir2html && \
    rm -rf /tmp/* /root/.cache /var/cache/apk/*

COPY --chmod=755 start.sh /start.sh

VOLUME [ "/out" ]
VOLUME [ "/Scan" ]

CMD [ "/start.sh" ]