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
    apk del --purge .build

CMD mkdir /etc/supervisor.d && \
    cat>/etc/supervisor.d/ss.conf<<EOF
    [supervisord]
    pidfile=/var/supervisord.pid
    nodaemon=true
    [program:ss]
    command = python /app/server.py
    stdout_logfile = /var/log/ssmu.log
    stderr_logfile = /var/log/ssmu.log
    user = root
    autostart = true
    autorestart = true
    EOF && \
    supervisord -c /etc/supervisor.d/ss.conf
