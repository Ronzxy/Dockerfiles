FROM skygangsta/nginx:1.16.1-alpine

ARG PHP_VERSION=7.3.9
ARG ZONE_NAME="Asia/Shanghai"
ARG USER=www
ARG GROUP=www

# 配置系统语言环境
RUN set -ex && \
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
    rm -rf /var/cache/apk/*

ENV LC_ALL=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8

# 安装依赖包
RUN set -ex && \
    apk upgrade && \
    apk add libjpeg-turbo libpng libxml2 libmcrypt libxpm libwebp libxslt libzip \
        zlib gmp gettext readline icu libbz2 libcurl freetype c-client \
        krb5-libs libldap libpq mariadb-connector-c-dev unixodbc net-snmp-libs tidyhtml-libs libssl1.1 && \
    rm -rf /var/cache/apk/*

ENV HTML_DATA_PATH=/usr/nginx/html

WORKDIR /usr/php

# 复制数据
COPY tz.php startup.sh dist/php-${PHP_VERSION}/ ./

RUN chmod 755 startup.sh && \
    > .dockerenv

EXPOSE 80 443

CMD ["./startup.sh", "start"]
