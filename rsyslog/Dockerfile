FROM alpine:edge

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=rsyslog
ARG GROUP=rsyslog

RUN set -ex && \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk upgrade && \
    apk add shadow tzdata rsyslog rsyslog-pgsql rsyslog-mysql logrotate && \
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
    apk del shadow tzdata && \
    rm -rf /var/cache/apk/*

ENV DISABLE_IMKLOG=TRUE
ENV DISABLE_IMMARK=TRUE
ENV DISABLE_DEBUG=TRUE

WORKDIR /

COPY rsyslog.d /etc/rsyslog.d.sample
COPY startup.sh backup.sh ./

RUN chmod 755 startup.sh backup.sh

ENTRYPOINT ["./startup.sh", "start"]
