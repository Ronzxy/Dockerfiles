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
ARG USER=etcd
ARG GROUP=etcd
ARG HOME=/usr/etcd

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

ARG ETCD_VERSION=3.4.9

RUN set -ex; \
    WORK_HOME="$(mktemp -d)" && cd ${WORK_HOME}; \
    # https://github.com/coreos/etcd/releases/download
    wget -c https://storage.googleapis.com/etcd/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
        -O ${WORK_HOME}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz; \
    apk add --no-cache coreutils bash; \
    tar xf ${WORK_HOME}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz -C ${WORK_HOME} --strip-components=1; \
    mv ${WORK_HOME}/etcd ${WORK_HOME}/etcdctl /usr/bin; \
    mkdir -p ${HOME}/data ${HOME}/cert; \
    chown -R ${USER}:${GROUP} ${HOME}; \
    rm -rf /tmp/* /var/cache/apk/*

VOLUME [ "${HOME}/data", "${HOME}/cert" ]

EXPOSE 2379-2380

USER ${USER}

CMD [ "etcd" ]
