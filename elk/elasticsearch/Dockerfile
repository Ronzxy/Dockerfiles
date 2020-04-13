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
    echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/main" >> /etc/apk/repositories; \
    echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories; \
    if [ "${ALPINE_VERSION}" = "edge" ]; then echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/testing" >> /etc/apk/repositories; fi; \
    apk upgrade --no-cache; \
    rm -rf /var/cache/apk/*

# 配置系统语言环境
RUN set -x; \
    GLIBC_VERSION=2.30-r0; \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub || \
        echo "Download error return $?"; \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk || \
        echo "Download error return $?"; \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk || \
        echo "Download error return $?"; \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk || \
        echo "Download error return $?"; \
    if [ ! -f /etc/apk/keys/sgerrand.rsa.pub ]; then wget -q http://file.openeasy.cn/alpine/sgerrand.rsa.pub \
        -O /etc/apk/keys/sgerrand.rsa.pub || exit 1; fi; \
    if [ ! -f glibc-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk || exit 1; fi; \
    if [ ! -f glibc-bin-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk || exit 1; fi; \
    if [ ! -f glibc-i18n-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk || exit 1; fi; \
    apk add --no-cache glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk; \
    rm -rf glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk; \
    rm -rf /var/cache/apk/*
RUN printf "zh_CN\nzh_HK\nzh_TW" | xargs -i /usr/glibc-compat/bin/localedef -c -f UTF-8 -i {} {}.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=elasticsearch
ARG GROUP=elasticsearch
ARG HOME=/usr/elasticsearch

RUN set -ex; \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories; \
    apk upgrade --no-cache; \
    apk add --no-cache shadow tzdata; \
    # 初始化时区
    cp /usr/share/zoneinfo/${ZONE_NAME} /etc/localtime && echo "Asia/Shanghai" > /etc/timezone; \
    # 初始化用户信息，将生产用户gid和uid与docker一致
    cat /etc/group | grep :999: | awk -F ':' '{print "groupmod -g 1999 "$1}' | sh; \
    cat /etc/passwd | grep :999: | awk -F ':' '{print "usermod -u 1999 "$1}' | sh; \
    cat /etc/group | grep ${GROUP}: | awk -F ':' '{print "groupmod -g 999 "$1}' | sh; \
    cat /etc/passwd | grep ${USER}: | awk -F ':' '{print "usermod -u 999 "$1}' | sh; \
    cat /etc/group | grep ${GROUP}: || sh -c "groupadd -r -g 999 ${GROUP}"; \
    cat /etc/passwd | grep ${USER}: || sh -c "useradd -r -u 999 -g ${GROUP} ${USER} -m -d ${HOME} -s /bin/sh"; \
    HOME=$(cat /etc/passwd | grep ${USER} | awk -F ':' '{print $6}'); \
    if [ ! -d ${HOME} ]; then mkdir -p ${HOME}; chown ${USER}:${GROUP} ${HOME}; fi; \
    apk del --no-cache --purge shadow; \
    rm -rf /var/cache/apk/*

ARG ELASTICSEARCH_VERSION=7.5.1

WORKDIR ${HOME}

USER ${USER}

RUN set -ex; \
    ELASTICSEARCH_VERSION_MAJOR=`printf ${ELASTICSEARCH_VERSION} | awk -F '.' '{print $1}'`; \
    ELASTICSEARCH_VERSION_MINOR=`printf ${ELASTICSEARCH_VERSION} | awk -F '.' '{print $2}'`; \
    ELASTICSEARCH_VERSION_BUILD=`printf ${ELASTICSEARCH_VERSION} | awk -F '.' '{print $3}'`; \
    wget "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz" \
        -O elasticsearch-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz; \
    su - ${USER} -c "tar xf elasticsearch-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz --strip-components=1 -C ${HOME}; \
        mkdir -p ${HOME}/data"; \
    apk add --no-cache openjdk11-jre; \
    rm -rf jdk elasticsearch-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz; \
    rm -rf /tmp/* /var/cache/apk/* 

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV CLUSTER_NAME=docker-elasticsearch
ENV DISCOVERY_SEED_HOSTS=""
# single-node
ENV DISCOVERY_TYPE=""

RUN set -ex; \
    sed -i "s/#network.host:.*/network.host: 0.0.0.0/g" config/elasticsearch.yml; \
    sed -i "s/#cluster.name:.*/cluster.name: ${CLUSTER_NAME}/g" config/elasticsearch.yml; \
    sed -i "s|#path.data:.*|&\npath.data: ${HOME}/data|g" config/elasticsearch.yml; \
    mv config/elasticsearch.yml config/elasticsearch.yml.default; \
    echo "cluster.name: ${CLUSTER_NAME}" >> config/elasticsearch.yml; \
    echo "network.host: 0.0.0.0" >> config/elasticsearch.yml; \
    echo "path.data: ${HOME}/data" >> config/elasticsearch.yml; \
    cp -af config config.default

USER root

COPY startup.sh ./

RUN set -ex; \
    chown -R ${USER}:${GROUP} startup.sh; \
    chmod 755 startup.sh

USER ${USER}

VOLUME [ "${HOME}/config", "${HOME}/logs", "${HOME}/data" ]

EXPOSE 9200 9300

CMD ["./startup.sh", "start"]
