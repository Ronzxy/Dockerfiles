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
ARG USER=kibana
ARG GROUP=kibana
ARG HOME=/usr/kibana

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
    apk del --no-cache --purge shadow; \
    rm -rf /tmp/* /var/cache/apk/*

ARG KIBANA_VERSION=7.6.2

WORKDIR ${HOME}

RUN set -ex; \
    KIBANA_VERSION_MAJOR=`printf ${KIBANA_VERSION} | awk -F '.' '{print $1}'`; \
    KIBANA_VERSION_MINOR=`printf ${KIBANA_VERSION} | awk -F '.' '{print $2}'`; \
    KIBANA_VERSION_BUILD=`printf ${KIBANA_VERSION} | awk -F '.' '{print $3}'`; \
    wget "https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz" \
        -O kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz; \
    apk add --no-cache libstdc++ nss expat libuuid coreutils; \
    su - ${USER} -c "tar xf kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz --strip-components=1"; \
    rm -rf kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz; \
    rm -rf /tmp/* /var/cache/apk/*

ENV SERVER_NAME=kibana-server
ENV SERVER_HOST=0.0.0.0
ENV ELASTICSEARCH_HOSTS=http://elasticsearch:9200
ENV XPACK_REPORTING_ENABLED=true

RUN set -ex; \
    sed -i "s/#server.port:.*/server.port: 5601/g" config/kibana.yml; \
    sed -i "s/#server.host:.*/server.host: 0.0.0.0/g" config/kibana.yml; \
    mv config/kibana.yml config/kibana.yml.default; \
    KIBANA_LOCALE=`echo $LANG | awk -F '.' '{print $1}' | awk -F '_' '{print $1"-"$2}'`; \
    echo "server.name: kibana-server" >> config/kibana.yml; \
    echo "server.host: 0" >> config/kibana.yml; \
    echo "elasticsearch.hosts: [ \"${ELASTICSEARCH_HOSTS}\" ]" >> config/kibana.yml; \
    echo "path.data: ${HOME}/data" >> config/kibana.yml; \
    echo "i18n.locale: \"${KIBANA_LOCALE}\"" >> config/kibana.yml; \
    mkdir -p logs && cp -af config config.default; \
    chown -R ${USER}:${GROUP} logs config config.default

COPY startup.sh ./

RUN set -ex; \
    chown -R ${USER}:${GROUP} startup.sh; \
    chmod 755 startup.sh

USER ${USER}

VOLUME [ "${HOME}/config", "${HOME}/logs", "${HOME}/data" ]

EXPOSE 5601

CMD ["./startup.sh", "start"]
