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
    tzdata \
    nginx \
    supervisor && \
    python3 -m pip install linuxdir2html && \
    rm -rf /tmp/* /root/.cache /var/cache/apk/*

COPY --chmod=755 ./conf /conf

RUN mkdir -p \
        /app \
        /etc/nginx/http.d \
    && \
    cp /conf/start.sh /start.sh && \
    cp /conf/linuxdir2html.conf /etc/nginx/http.d/linuxdir2html.conf && \
    cp /conf/supervisord.conf /app/supervisord.conf && \
    chmod 777 \
        /start.sh \
        /etc/nginx/http.d/linuxdir2html.conf \
        /app/supervisord.conf \
    && \
    rm -rf /conf

VOLUME [ "/out" ]
VOLUME [ "/Scan" ]

EXPOSE 4774

CMD [ "/start.sh" ]