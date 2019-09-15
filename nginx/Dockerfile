FROM alpine:edge

ARG NGINX_VERSION=1.16.1
ARG ZONE_NAME="Asia/Shanghai"
ARG USER=www
ARG GROUP=www

RUN set -ex && \
    # echo http://dl-cdn.alpinelinux.org/alpine/edge/main/ >> /etc/apk/repositories && \
    # echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && \
    # echo http://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
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
    apk add zlib pcre libssl1.1 && \
    rm -rf /var/cache/apk/*

ENV HTML_DATA_PATH=/usr/nginx/html

WORKDIR /usr/nginx

# 复制数据
COPY startup.sh dist/nginx-${NGINX_VERSION}/ ./

RUN chmod 755 startup.sh && \
    mv conf conf.example && \
    mv html html.example && \
    > .dockerenv

EXPOSE 80 443

CMD ["./startup.sh", "start"]
