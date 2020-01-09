FROM alpine:edge

# 配置系统语言环境
RUN set -x && \
    GLIBC_VERSION=2.30-r0 && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub || \
        echo "Download error return $?" && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk || \
        echo "Download error return $?" && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk || \
        echo "Download error return $?" && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk || \
        echo "Download error return $?" && \
    if [ ! -f /etc/apk/keys/sgerrand.rsa.pub ]; then wget -q http://file.openeasy.cn/alpine/sgerrand.rsa.pub \
        -O /etc/apk/keys/sgerrand.rsa.pub || exit 1; fi && \
    if [ ! -f glibc-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk || exit 1; fi && \
    if [ ! -f glibc-bin-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk || exit 1; fi && \
    if [ ! -f glibc-i18n-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk || exit 1; fi && \
    apk add glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk && \
    rm -rf glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk && \
    rm -rf /var/cache/apk/*
RUN printf "zh_CN\nzh_HK\nzh_TW" | xargs -i /usr/glibc-compat/bin/localedef -c -f UTF-8 -i {} {}.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=logstash
ARG GROUP=logstash
ARG HOME=/usr/logstash

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
    cat /etc/passwd | grep ${USER}: | awk -F ':' '{print "usermod -u 999 "$1}' | sh && \
    cat /etc/group | grep ${GROUP}: || sh -c "groupadd -r -g 999 ${GROUP}" && \
    cat /etc/passwd | grep ${USER}: || sh -c "useradd -r -u 999 -g ${GROUP} ${USER} -m -d ${HOME} -s /bin/sh" && \
    HOME=$(cat /etc/passwd | grep ${USER} | awk -F ':' '{print $6}') && \
    if [ ! -d ${HOME} ]; then mkdir -p ${HOME}; chown ${USER}:${GROUP} ${HOME}; fi && \
    apk del shadow && \
    rm -rf /var/cache/apk/*

ARG LOGSTASH_VERSION=7.5.1

WORKDIR ${HOME}

USER ${USER}

RUN set -ex && \
    LOGSTASH_VERSION_MAJOR=`printf ${LOGSTASH_VERSION} | awk -F '.' '{print $1}'` && \
    LOGSTASH_VERSION_MINOR=`printf ${LOGSTASH_VERSION} | awk -F '.' '{print $2}'` && \
    LOGSTASH_VERSION_BUILD=`printf ${LOGSTASH_VERSION} | awk -F '.' '{print $3}'` && \
    wget "https://artifacts.elastic.co/downloads/logstash/logstash-${LOGSTASH_VERSION}.tar.gz" \
        -O logstash-${LOGSTASH_VERSION}.tar.gz

RUN set -ex && \
    tar xf logstash-${LOGSTASH_VERSION}.tar.gz --strip-components=1 && \
    rm -rf logstash-${LOGSTASH_VERSION}.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV LOGSTASH_DATA=/var/lib/logstash
ENV NODE_NAME=logstath-server
ENV ELASTICSEARCH_HOSTS=http://elasticsearch:9200

RUN set -ex && \
    mkdir logs && \
    cp -af config config.default

USER root

RUN set -ex && \
    apk add openjdk11-jre && \
    rm -rf /tmp/* /var/cache/apk/*

COPY startup.sh ./

RUN mkdir -p ${LOGSTASH_DATA} && \
    chown -R ${USER}:${GROUP} ${LOGSTASH_DATA} startup.sh && \
    chmod 755 startup.sh

USER ${USER}

VOLUME [ "${HOME}/config", "${HOME}/logs", "${LOGSTASH_DATA}" ]

EXPOSE 5044 9600

CMD ["./startup.sh", "start"]
