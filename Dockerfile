FROM python:3.9.2-alpine

COPY . /app
WORKDIR /app

RUN apk add --no-cache \
        supervisor \
        gcc \
        libsodium-dev \
        libffi-dev \
        openssl-dev && \
    apk add --no-cache --virtual .build \
        libc-dev \
        rust \
        cargo && \
    pip install --no-cache-dir -r requirements.txt && \
    cp docker-apiconfig.py userapiconfig.py && \
    apk del --purge .build && \
    mkdir /etc/supervisor.d && \
    echo $'[supervisord] \n\
pidfile=/var/supervisord.pid \n\
nodaemon=true \n\
[program:ss] \n\
command = python /app/server.py \n\
stdout_logfile = /var/log/ssmu.log \n\
stderr_logfile = /var/log/ssmu.log \n\
user = root \n\
autostart = true \n\
autorestart = true' >> /etc/supervisor.d/ss.conf

CMD supervisord -c /etc/supervisor.d/ss.conf
