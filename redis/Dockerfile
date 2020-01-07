FROM alpine:edge

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=redis
ARG GROUP=redis
ARG HOME=/home/${USER}

RUN set -ex && \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk upgrade && \
    apk add shadow tzdata && \
    # 初始化时区
    cp /usr/share/zoneinfo/${ZONE_NAME} /etc/localtime && echo "Asia/Shanghai" > /etc/timezone && \
    # 初始化用户信息，将生产用户gid和uid与docker一致
    cat /etc/group | grep :999: | awk -F ':' '{print "groupmod -g 1999 "$1}' | sh && \
    cat /etc/passwd | grep :999: | awk -F ':' '{print "usermod -u 1999 "$1}' | sh && \
    cat /etc/group | grep ${GROUP}: | awk -F ':' '{print "groupmod -g 999 "$1}' | sh && \
    cat /etc/passwd | grep ${USER}: | awk -F ':' '{print "usermod -u 999 -m -d ${HOME} "$1}' | sh && \
    cat /etc/group | grep ${GROUP}: || sh -c "groupadd -r -g 999 ${GROUP}" && \
    cat /etc/passwd | grep ${USER}: || sh -c "useradd -r -u 999 -g ${GROUP} ${USER} -m -d ${HOME} -s /bin/sh" && \
    HOME=$(cat /etc/passwd | grep ${USER} | awk -F ':' '{print $6}') && \
    if [ ! -d ${HOME} ]; then mkdir -p ${HOME}; chown ${USER}:${GROUP} ${HOME}; fi && \
    apk del shadow tzdata && \
    rm -rf /var/cache/apk/*

ENV REDIS_PORT=6379
ENV REDIS_DATA=/var/lib/redis
ENV APPEND_ONLY=yes
ENV CLUSTER_ENABLE=no

VOLUME [ "${REDIS_DATA}" ]

WORKDIR /usr/redis

ARG REDIS_VERSION=5.0.5

# 复制数据
COPY startup.sh dist/redis-${REDIS_VERSION}/ ./

RUN chmod 755 startup.sh && \
    > .dockerenv

EXPOSE ${REDIS_PORT} 1${REDIS_PORT}

ENTRYPOINT ["./startup.sh", "start"]
