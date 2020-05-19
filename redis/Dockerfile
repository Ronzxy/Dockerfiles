FROM alpine:latest

ARG ALPINE_VERSION=latest-stable

RUN set -ex; \
    echo "" > /etc/apk/repositories; \
    if [ "${ALPINE_VERSION}" != "edge" ]; then ALPINE_VERSION=v`cat /etc/alpine-release | awk -F '.' '{print $1"."$2}'`; fi; \
    echo "https://mirrors.aliyun.com/alpine/${ALPINE_VERSION}/main" >> /etc/apk/repositories; \
    echo "https://mirrors.aliyun.com/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories; \
    if [ "${ALPINE_VERSION}" = "edge" ]; then echo "https://mirrors.aliyun.com/alpine/${ALPINE_VERSION}/testing" >> /etc/apk/repositories; fi; \
    echo "https://mirrors.ustc.edu.cn/alpine/${ALPINE_VERSION}/main" >> /etc/apk/repositories; \
    echo "https://mirrors.ustc.edu.cn/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories; \
    if [ "${ALPINE_VERSION}" = "edge" ]; then echo "https://mirrors.ustc.edu.cn/alpine/${ALPINE_VERSION}/testing" >> /etc/apk/repositories; fi; \
    # echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/main" >> /etc/apk/repositories; \
    # echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories; \
    # if [ "${ALPINE_VERSION}" = "edge" ]; then echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/testing" >> /etc/apk/repositories; fi; \
    apk upgrade --no-cache; \
    rm -rf /tmp/* /var/cache/apk/*

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=redis
ARG GROUP=redis
ARG HOME=/usr/redis

RUN set -ex; \
    apk add --no-cache shadow tzdata; \
    # 初始化时区
    cp /usr/share/zoneinfo/${ZONE_NAME} /etc/localtime && echo "Asia/Shanghai" > /etc/timezone; \
    # 初始化用户信息，将生产用户gid和uid与docker一致
    cat /etc/group | grep :999: | awk -F ':' '{print "groupmod -g 1999 "$1}' | sh; \
    cat /etc/passwd | grep :999: | awk -F ':' '{print "usermod -u 1999 "$1}' | sh; \
    cat /etc/group | grep ${GROUP}: | awk -F ':' '{print "groupmod -g 999 "$1}' | sh; \
    cat /etc/passwd | grep ${USER}: | awk -F ':' '{print "usermod -u 999 -m -d ${HOME} "$1}' | sh; \
    cat /etc/group | grep ${GROUP}: || sh -c "groupadd -r -g 999 ${GROUP}"; \
    cat /etc/passwd | grep ${USER}: || sh -c "useradd -r -u 999 -g ${GROUP} ${USER} -m -d ${HOME} -s /bin/sh"; \
    HOME=$(cat /etc/passwd | grep ${USER} | awk -F ':' '{print $6}'); \
    if [ ! -d ${HOME} ]; then mkdir -p ${HOME}; chown ${USER}:${GROUP} ${HOME}; fi; \
    apk del --no-cache --purge shadow tzdata; \
    rm -rf /tmp/* /var/cache/apk/*

ARG REDIS_VERSION=6.0.0

RUN set -ex; \
    WORK_HOME="$(mktemp -d)" && cd ${WORK_HOME}; \
    wget -c http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz \
        -O ${WORK_HOME}/redis-${REDIS_VERSION}.tar.gz; \
    # wget -c https://github.com/antirez/redis/archive/${REDIS_VERSION}.tar.gz \
    #     -O ${WORK_HOME}/redis-${REDIS_VERSION}.tar.gz; \
    apk add --no-cache build-base linux-headers coreutils; \
    tar xf ${WORK_HOME}/redis-${REDIS_VERSION}.tar.gz -C ${WORK_HOME}; \
    cd ${WORK_HOME}/redis-${REDIS_VERSION}; \
    make -j "$(nproc)" PREFIX=${HOME} install; \
    mkdir -p ${HOME}/conf; \
    cp *.conf ${HOME}/conf; \
    apk del --no-cache --purge build-base linux-headers; \
    rm -rf /tmp/* /var/cache/apk/*

ENV REDIS_PORT=6379
ENV REDIS_DATA=/var/lib/redis
ENV APPEND_ONLY=yes
ENV CLUSTER_ENABLE=no

VOLUME [ "${REDIS_DATA}" ]

WORKDIR ${HOME}

# 复制数据
COPY startup.sh ./

RUN chmod 755 startup.sh; \
    > .dockerenv

EXPOSE ${REDIS_PORT} 1${REDIS_PORT}

ENTRYPOINT ["./startup.sh", "start"]
