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

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=filebeat
ARG GROUP=filebeat
ARG HOME=/usr/filebeat

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

ARG FILEBEAT_VERSION=7.6.2

WORKDIR ${HOME}

RUN set -ex; \
    FILEBEAT_VERSION_MAJOR=`printf ${FILEBEAT_VERSION} | awk -F '.' '{print $1}'`; \
    FILEBEAT_VERSION_MINOR=`printf ${FILEBEAT_VERSION} | awk -F '.' '{print $2}'`; \
    FILEBEAT_VERSION_BUILD=`printf ${FILEBEAT_VERSION} | awk -F '.' '{print $3}'`; \
    wget "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-$(uname -s | tr 'A-Z' 'a-z')-$(uname -m).tar.gz" \
        -O filebeat-${FILEBEAT_VERSION}.tar.gz; \
    su - ${USER} -c "tar xf filebeat-${FILEBEAT_VERSION}.tar.gz --strip-components=1 -C ${HOME}"; \
    mkdir -p ${HOME}/config ${HOME}/data ${HOME}/logs; \
    rm -rf filebeat-${FILEBEAT_VERSION}.tar.gz

ENV NODE_NAME=filebeat
ENV ELASTICSEARCH_HOSTS=http://elasticsearch:9200
ENV ELASTICSEARCH_USERNAME=""
ENV ELASTICSEARCH_PASSWORD=""
ENV KIBANA_HOSTS=http://kibana:5601
ENV SETUP_ILM_ROLLOVER_ALIAS="filebeat-%{[agent.version]}"
ENV SETUP_ILM_PATTERN="{now/d}-000001"
ENV SETUP_ILM_OVERWRITE=false
ENV INPUT_FILE_PATTERN_LIST=""
ENV OUTPUT_FIELDS=""

COPY startup.sh ./
COPY config ./config

RUN cp -af config config.default; \
    chown -R ${USER}:${GROUP} ${HOME}/config* ${HOME}/data ${HOME}/logs startup.sh; \
    chmod 755 startup.sh

USER ${USER}

VOLUME [ "${HOME}/config", "${HOME}/data", "${HOME}/logs" ]

CMD ["./startup.sh", "start"]
