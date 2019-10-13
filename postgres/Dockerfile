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
ARG USER=postgres
ARG GROUP=postgres

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

# 安装依赖包
RUN set -ex && \
    apk upgrade && \
    apk add zlib libssl1.1 libxml2 readline libxslt libcurl ossp-uuid libselinux icu-libs flex bison geos proj gdal && \
    rm -rf /var/cache/apk/*

    # # --enable-tap-tests \
    # apk add perl-ipc-run

    # # --enable-nls="zh_CN" 在 alpine 会产生编译错误
    # apk add gettext

    # # 这些功能会造成容器尺寸非常巨大
    # # --with-gssapi \
    # # --with-ldap \
    # # --with-tcl \
    # # --with-perl \
    # # --with-python \
    # # --with-pam \
    # apk add krb5-libs libldap linux-pam python3 tcl perl


ARG POSTGRES_VERSION=12.0

ENV PGDATA="/var/lib/postgres"
ENV POSTGRES_PASSWORD=""
ENV NETWORK="127.0.0.1/32"
# MASTER/BACKUP
ENV PGTYPE="MASTER"
ENV PGMASTER_HOST=""
ENV PGMASTER_PORT=5432
# SYNC
ENV SYNC_MODE=NONE
ENV SYNC_NAME=""

WORKDIR /usr/postgres

# 复制数据
COPY startup.sh dist/postgres-${POSTGRES_VERSION}/ ./

RUN chmod 755 startup.sh && \
    > .dockerenv

EXPOSE 5432

CMD ["./startup.sh", "start"]
