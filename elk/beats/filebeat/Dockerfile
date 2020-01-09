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
ARG USER=filebeat
ARG GROUP=filebeat
ARG HOME=/usr/filebeat

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

ARG FILEBEAT_VERSION=7.5.1

WORKDIR ${HOME}

USER ${USER}

RUN set -ex && \
    FILEBEAT_VERSION_MAJOR=`printf ${FILEBEAT_VERSION} | awk -F '.' '{print $1}'` && \
    FILEBEAT_VERSION_MINOR=`printf ${FILEBEAT_VERSION} | awk -F '.' '{print $2}'` && \
    FILEBEAT_VERSION_BUILD=`printf ${FILEBEAT_VERSION} | awk -F '.' '{print $3}'` && \
    wget "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-$(uname -s | tr 'A-Z' 'a-z')-$(uname -m).tar.gz" \
        -O filebeat-${FILEBEAT_VERSION}.tar.gz

RUN set -ex && \
    tar xf filebeat-${FILEBEAT_VERSION}.tar.gz --strip-components=1 && \
    rm -rf filebeat-${FILEBEAT_VERSION}.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV NODE_NAME=filebeat
ENV ELASTICSEARCH_HOSTS=http://elasticsearch:9200
ENV ELASTICSEARCH_USERNAME=""
ENV ELASTICSEARCH_PASSWORD=""
ENV KIBANA_HOSTS=http://kibana:5601
ENV SETUP_ILM_ROLLOVER_ALIAS="filebeat-%{[agent.version]}"
ENV SETUP_ILM_PATTERN="{now/d}-000001"
ENV SETUP_ILM_OVERWRITE=false
ENV SETUP_ILM_POLICY_NAME="filebeat-%{[agent.version]}"
ENV SETUP_ILM_POLICY_MAX_SIZE=50GB
ENV SETUP_ILM_POLICY_MIN_AGE=30d
ENV INPUT_FILE_PATTERN_LIST=""
ENV OUTPUT_FIELDS=""

USER root

RUN mkdir -p ${HOME}/config/default ${HOME}/data ${HOME}/logs && \
    mv kibana module modules.d fields.yml config && \
    mv filebeat.reference.yml filebeat.yml config/default

COPY config startup.sh ./

RUN mv policy filebeat.yml config && \
    cp -af config config.default && \
    chown -R ${USER}:${GROUP} ${HOME}/config* ${HOME}/data ${HOME}/logs startup.sh && \
    chmod 755 startup.sh

USER ${USER}

VOLUME [ "${HOME}/config", "${HOME}/data", "${HOME}/logs" ]

CMD ["./startup.sh", "start"]
