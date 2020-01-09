FROM alpine:3.9

ARG ALPINE_VERSION=3.9

RUN set -ex && \
    echo "" > /etc/apk/repositories && \
    if [ "${ALPINE_VERSION}" != "edge" ]; then ALPINE_VERSION=v`cat /etc/alpine-release | awk -F '.' '{print $1"."$2}'`; fi && \
    echo "https://mirrors.aliyun.com/alpine/${ALPINE_VERSION}/main" >> /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    if [ "${ALPINE_VERSION}" = "edge" ]; then echo "https://mirrors.aliyun.com/alpine/${ALPINE_VERSION}/testing" >> /etc/apk/repositories; fi && \
    echo "https://mirrors.ustc.edu.cn/alpine/${ALPINE_VERSION}/main" >> /etc/apk/repositories && \
    echo "https://mirrors.ustc.edu.cn/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    if [ "${ALPINE_VERSION}" = "edge" ]; then echo "https://mirrors.ustc.edu.cn/alpine/${ALPINE_VERSION}/testing" >> /etc/apk/repositories; fi && \
    echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    if [ "${ALPINE_VERSION}" = "edge" ]; then echo "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/testing" >> /etc/apk/repositories; fi && \
    apk upgrade

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
    if [ ! -f /etc/apk/keys/sgerrand.rsa.pub ]; then wget -q http://file.openeasy.cn/alpine/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub || exit 1; fi && \
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
ARG USER=jumpserver
ARG GROUP=jumpserver
ARG HOME=/usr/jumpserver

RUN set -ex && \
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
    apk del shadow && \
    rm -rf /var/cache/apk/*

ARG JUMPSERVER_VERSION=1.5.6
ARG JUMPSERVER_HOME=${HOME}
WORKDIR ${JUMPSERVER_HOME}

# 安装依赖包
RUN set -ex && \
    wget https://github.com/jumpserver/jumpserver/archive/${JUMPSERVER_VERSION}.tar.gz \
        -O jumpserver-${JUMPSERVER_VERSION}.tar.gz && \
    wget https://github.com/jumpserver/luna/releases/download/${JUMPSERVER_VERSION}/luna.tar.gz \
        -O luna-${JUMPSERVER_VERSION}.tar.gz && \
    tar xf jumpserver-${JUMPSERVER_VERSION}.tar.gz --strip-components=1 && \
    tar xf luna-${JUMPSERVER_VERSION}.tar.gz && \
    chown -R ${USER}:${GROUP} ${JUMPSERVER_HOME} && \
    apk --no-cache add $(cat ${JUMPSERVER_HOME}/requirements/alpine_requirements.txt) && \
    rm -rf jumpserver-${JUMPSERVER_VERSION}.tar.gz luna-${JUMPSERVER_VERSION}.tar.gz /var/cache/apk/* /tmp/*

RUN set -ex && \
    pip3 install --upgrade pip setuptools wheel -i https://mirrors.aliyun.com/pypi/simple/ && \
    sed -i "s/mysqlclient.*/postgres==2.2.2\\n&/g" ${JUMPSERVER_HOME}/requirements/requirements.txt && \
    pip3 install -r ${JUMPSERVER_HOME}/requirements/requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ && \
    rm -rf /tmp/* ${JUMPSERVER_HOME}/.cache

# postgresql/mysql
ENV DB_ENGINE=postgresql
ENV DB_HOST=172.17.0.1
ENV DB_PORT=5432
ENV DB_NAME=jumpserver
ENV DB_USER=jumpserver
ENV DB_PASSWORD=Abc123

ENV REDIS_HOST=172.17.0.1
ENV REDIS_PORT=6379
ENV REDIS_PASSWORD=
ENV REDIS_DB_CELERY=
ENV REDIS_DB_CACHE=

ENV SECRET_KEY=
ENV BOOTSTRAP_TOKEN=

ENV DEBUG=false
# DEBUG/ERROR
ENV LOG_LEVEL=ERROR


ADD startup.sh jumpserver.conf ./

RUN chmod 755 startup.sh && \
    > .dockerenv

EXPOSE 8080

CMD ["./startup.sh"]
