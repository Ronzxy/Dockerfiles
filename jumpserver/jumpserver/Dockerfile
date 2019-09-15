FROM alpine:3.9

ARG JUMPSERVER_VERSION=1.5.2
ARG ZONE_NAME="Asia/Shanghai"
ARG USER=jumpserver
ARG GROUP=jumpserver

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
    cat /etc/passwd | grep ${USER}: || sh -c "useradd -r -u 999 -g ${GROUP} ${USER} -m -d /home/${USER} -s /bin/sh" && \
    HOME=$(cat /etc/passwd | grep www | awk -F ':' '{print $6}') && \
    if [ ! -d ${HOME} ]; then mkdir -p ${HOME}; fi && \
    apk del shadow && \
    rm -rf /var/cache/apk/*

# # 配置系统语言环境
# RUN set -ex && \
#     GLIBC_VERSION=2.30-r0 && \
#     wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
#     wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
#     wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
#     wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
#     apk add glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk && \
#     rm -rf glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk && \
#     rm -rf /var/cache/apk/*
# RUN printf "zh_CN\nzh_HK\nzh_TW" | xargs -i /usr/glibc-compat/bin/localedef -c -f UTF-8 -i {} {}.UTF-8
# ENV LC_ALL=zh_CN.UTF-8
# ENV LANG=zh_CN.UTF-8

RUN set -x && \
    GLIBC_VERSION=2.30-r0 && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
    if [ ! -f /etc/apk/keys/sgerrand.rsa.pub ]; then wget -q -O /etc/apk/keys/sgerrand.rsa.pub http://file.openeasy.cn/alpine/sgerrand.rsa.pub || exit 1; fi && \
    if [ ! -f glibc-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk || exit 1; fi && \
    if [ ! -f glibc-bin-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk || exit 1; fi && \
    if [ ! -f glibc-i18n-${GLIBC_VERSION}.apk ]; then wget -q http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk || exit 1; fi && \
    apk add glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk && \
    printf "zh_CN\nzh_HK\nzh_TW" | xargs -i /usr/glibc-compat/bin/localedef -c -f UTF-8 -i {} {}.UTF-8 && \
    apk del glibc-bin glibc-i18n glibc && rm -rf /etc/apk/keys/sgerrand.rsa.pub && \
    rm -rf glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk && \
    rm -rf /var/cache/apk/* && echo 1 && exit 1


# # echo http://dl-2.alpinelinux.org/alpine/edge/main/ >> /etc/apk/repositories && \
# # echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && \
# RUN set -ex && \
#     apk --no-cache add ca-certificates wget shadow && \
#     rm -rf /var/cache/apk/*

# # 配置系统语言环境
# RUN set -ex && \
#     GLIBC_VERSION=2.30-r0 && \
#     wget -nv -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
#     wget -nv http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
#     wget -nv http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
#     wget -nv http://file.openeasy.cn/alpine/glibc/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
#     apk add glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk && \
#     rm -rf glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk

# RUN printf "zh_CN" | xargs -i /usr/glibc-compat/bin/localedef -c -f UTF-8 -i {} {}.UTF-8
# ENV LC_ALL=zh_CN.UTF-8
# ENV LANG=zh_CN.UTF-8

# RUN echo "Asia/Shanghai" > /etc/timezone && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# RUN cat /etc/group | grep :999: | awk -F ':' '{print "groupmod -g 1999 "$1}' | sh && \
#     groupadd -r -g 999 jumpserver && \
#     useradd -r -u 999 -g jumpserver jumpserver -m -d /home/jumpserver -s /bin/bash

ARG JUMPSERVER_HOME=/usr/jumpserver

WORKDIR ${JUMPSERVER_HOME}

ADD src/jumpserver-${JUMPSERVER_VERSION}.tar.gz ./

# 安装依赖包
RUN set -ex && \
    mv ${JUMPSERVER_HOME}/jumpserver-${JUMPSERVER_VERSION}/* ${JUMPSERVER_HOME} && \
    rm -rf ${JUMPSERVER_HOME}/jumpserver-${JUMPSERVER_VERSION} && \
    sed -i "s/mysqlclient.*/postgres==2.2.2\\n&/g" ${JUMPSERVER_HOME}/requirements/requirements.txt && \
    # apk --no-cache add bash && \
    apk --no-cache add $(cat ${JUMPSERVER_HOME}/requirements/alpine_requirements.txt) && \
    rm -rf /var/cache/apk/* && \
    pip3 install --upgrade pip setuptools -i https://mirrors.aliyun.com/pypi/simple/ && \
    pip3 install -r  ${JUMPSERVER_HOME}/requirements/requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ && \
    rm -rf /root/.cache

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

ENV SECRET_KEY=ww2ZkPHHXbe5ydtpdkG0FoYrSjAnxRfx6RJAqlE959ThckZhHF
ENV BOOTSTRAP_TOKEN=DdC9ASWbpzq6WACk

ENV DEBUG=false
# DEBUG/ERROR
ENV LOG_LEVEL=ERROR


ADD startup.sh jumpserver.conf src/luna-${JUMPSERVER_VERSION}.tar.gz ./

RUN chmod 755 startup.sh && \
    > .dockerenv

EXPOSE 8080

ENTRYPOINT ["./startup.sh"]
