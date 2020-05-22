FROM alpine:3.11

ARG ALPINE_VERSION=3.11

RUN set -ex; \
    > /etc/apk/repositories; \
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
    rm -rf /tmp/* /var/cache/apk/*

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=mysql
ARG GROUP=mysql
ARG HOME=/var/lib/mysql

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

ARG MARIADB_VERSION=10.4

RUN set -ex; \
    apk add --no-cache coreutils mariadb mariadb-client; \
    rm -rf /tmp/* /var/cache/apk/*

    # WORK_HOME="$(mktemp -d)"; \
    # apk add coreutils bison ncurses-libs gnutls libxml2 libexecinfo libcurl \
    #     build-base cmake git ncurses-dev gnutls-dev libxml2-dev libexecinfo-dev curl-dev; \
    # # build-base openssl-dev zlib-dev mariadb-connector-c-dev bison cmake curl-dev \
    # # libaio-dev libarchive-dev libevent-dev libxml2-dev ncurses-dev pcre-dev readline-dev \
    # # xz-dev linux-headers linux-pam-dev perl perl-dbi perl-dbd-mysql perl-getopt-long perl-socket perl-term-readkey
    # # git clone --depth 1 -b ${MARIADB_VERSION} --single-branch https://github.com/MariaDB/server mariadb; \
    # wget https://downloads.mariadb.org/f/mariadb-${MARIADB_VERSION}/source/mariadb-${MARIADB_VERSION}.tar.gz?serve \
    #     -O ${WORK_HOME}/mariadb-${MARIADB_VERSION}.tar.gz; \
    # tar xf ${WORK_HOME}/mariadb-${MARIADB_VERSION}.tar.gz -C ${WORK_HOME}; \
    #     cd ${WORK_HOME}/mariadb-${MARIADB_VERSION}; \
    # cmake . -DWITH_TOKUDB=0; \
    # make -j "$(nproc)"; \
    # make install
WORKDIR ${HOME}

ENV MYSQL_DATA_PATH="${HOME}"
ENV MYSQL_ROOT_PASSWORD=""

EXPOSE 3306

VOLUME [ "${MYSQL_DATA_PATH}" "/etc/my.cnf.d" ]

# 复制数据
COPY startup.sh /usr/bin

RUN chmod 755 /usr/bin/startup.sh; \
    printf "USER=%s\nGROUP=%s\n" ${USER} ${GROUP} > /.dockerenv

EXPOSE 5432

CMD ["startup.sh", "start"]
