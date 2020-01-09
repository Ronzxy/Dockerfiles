FROM alpine:latest

ARG ALPINE_VERSION=latest-stable

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
    rm -rf glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk glibc-${GLIBC_VERSION}.apk
RUN printf "zh_CN\nzh_HK\nzh_TW" | xargs -i /usr/glibc-compat/bin/localedef -c -f UTF-8 -i {} {}.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=postgres
ARG GROUP=postgres
ARG HOME=/usr/postgres

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
    apk del shadow

ARG POSTGRES_VERSION=12.1
ARG CITUS_VERSION=9.1.2
ARG HLL_VERSION=2.14
ARG POSTGIS_VERSION=3.0.0

# 安装编译工具及依赖
RUN set -ex && \
    WORK_HOME="$(mktemp -d)" && cd ${WORK_HOME} && \
    wget https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.bz2 \
        -O ${WORK_HOME}/postgresql-${POSTGRES_VERSION}.tar.bz2 && \
    wget https://github.com/citusdata/citus/archive/v${CITUS_VERSION}.tar.gz \
        -O ${WORK_HOME}/citus-${CITUS_VERSION}.tar.gz && \
    wget https://github.com/citusdata/postgresql-hll/archive/v${HLL_VERSION}.tar.gz \
        -O ${WORK_HOME}/postgresql-hll-${HLL_VERSION}.tar.gz && \
    wget https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz \
        -O ${WORK_HOME}/postgis-${POSTGIS_VERSION}.tar.gz && \
    # 安装依赖
    apk add zlib libssl1.1 libxml2 readline libxslt libcurl libselinux icu-libs json-c flex bison geos proj gdal perl && \
    # # --enable-tap-tests \
    # apk add perl-ipc-run
    #
    # # --enable-nls="zh_CN" 在 alpine 会产生编译错误
    # apk add gettext
    #
    # # 这些功能会造成容器尺寸非常巨大
    # # --with-gssapi \
    # # --with-ldap \
    # # --with-tcl \
    # # --with-perl \
    # # --with-python \
    # # --with-pam \
    # apk add krb5-libs libldap linux-pam python3 tcl perl
    apk add build-base \
        zlib-dev libxml2-dev openssl-dev readline-dev libxslt-dev curl-dev \
        libselinux-dev icu-dev flex bison geos-dev proj-dev gdal-dev linux-headers json-c-dev perl-dev && \
    # # --enable-tap-tests \
    # apk add perl-ipc-run
    #
    # # --enable-nls="zh_CN" 在 alpine 会产生编译错误
    # apk add gettext-dev
    #
    # # 这些功能会造成容器尺寸非常巨大
    # # --with-gssapi \
    # # --with-ldap \
    # # --with-tcl \
    # # --with-perl \
    # # --with-python \
    # # --with-pam \
    # apk add krb5-dev openldap-dev linux-pam-dev python3-dev tcl-dev perl-dev
    #
    # # configure: error: prove not found
    # apk add perl-utils
    tar xf ${WORK_HOME}/postgresql-${POSTGRES_VERSION}.tar.bz2 -C ${WORK_HOME} && \
    cd ${WORK_HOME}/postgresql-${POSTGRES_VERSION} && \
    ./configure --prefix=${HOME} \
        --enable-integer-datetimes \
		--enable-thread-safety \
		--disable-rpath \
		--with-gnu-ld \
        --with-libedit-preferred \
		--with-system-tzdata=/usr/share/zoneinfo \
        --with-zlib \
		--with-openssl \
		--with-libxml \
		--with-libxslt \
		--with-icu \
        --with-selinux \
        --with-libraries=${HOME}/lib/ \
        --with-includes=${HOME}/include/ && \
    # --enable-tap-tests \
    # --enable-nls="zh_CN zh_TW" \
    # # 忽略 debuginfo 保持较小的程序尺寸
    # --enable-debug \
    # # 这些功能会造成容器尺寸非常巨大
    # --with-gssapi \
    # --with-ldap \
    # --with-tcl \
    # --with-perl \
    # --with-python \
    # --with-pam \
    make -j "$(nproc)" && \
    make install && \
    cd ${WORK_HOME}/postgresql-${POSTGRES_VERSION}/contrib && \
    # 编译外围模块
    make -j "$(nproc)" && \
    make install && \
    # 编译隔离测试脚本
    cd ${WORK_HOME}/postgresql-${POSTGRES_VERSION}/src/test/isolation && \
    make -j "$(nproc)" && \
    make install && \
    export PATH=${HOME}/bin:${PATH} && \
    # 编译 citus 扩展
    tar xf ${WORK_HOME}/citus-${CITUS_VERSION}.tar.gz -C ${WORK_HOME} && \
    cd ${WORK_HOME}/citus-${CITUS_VERSION} && \
    ./configure --prefix=${HOME} && \
    make -j "$(nproc)" && \
    make install && \
    # 编译 hll 扩展
    tar xf ${WORK_HOME}/postgresql-hll-${HLL_VERSION}.tar.gz -C ${WORK_HOME} && \
    cd ${WORK_HOME}/postgresql-hll-${HLL_VERSION} && \
    make -j "$(nproc)" && \
    make install && \
    # 编译 postgis 扩展
    tar xf ${WORK_HOME}/postgis-${POSTGIS_VERSION}.tar.gz -C ${WORK_HOME} && \
    cd ${WORK_HOME}/postgis-${POSTGIS_VERSION} && \
    ./configure --prefix=${HOME} && \
    make -j "$(nproc)" && \
    make install && \
    # 清理编译依赖
    apk del build-base \
        zlib-dev libxml2-dev openssl-dev readline-dev libxslt-dev curl-dev \
        libselinux-dev icu-dev flex bison geos-dev proj-dev gdal-dev linux-headers json-c-dev && \
    # 再次确认依赖
    apk add zlib libssl1.1 libxml2 readline libxslt libcurl libselinux icu-libs json-c flex bison geos proj gdal perl && \
    # 清理数据
    rm -rf /tmp/* /var/cache/apk/*

ENV PGDATA="/var/lib/postgres/data"
ENV POSTGRES_PASSWORD=""
ENV NETWORK="127.0.0.1/32"
# MASTER/BACKUP
ENV PGTYPE="MASTER"
ENV PGMASTER_HOST=""
ENV PGMASTER_PORT=5432
# SYNC
ENV SYNC_MODE=NONE
ENV SYNC_NAME=""

VOLUME ${PGDATA}

WORKDIR ${HOME}

# 复制数据
COPY startup.sh ./

RUN chmod 755 startup.sh && \
    printf "USER=%s\nGROUP=%s\n" ${USER} ${GROUP} > .dockerenv

EXPOSE 5432

CMD ["./startup.sh", "start"]
