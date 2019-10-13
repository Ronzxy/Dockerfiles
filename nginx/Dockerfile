FROM alpine:edge

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=www
ARG GROUP=www

RUN set -ex && \
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
    apk del shadow tzdata && \
    rm -rf /var/cache/apk/*

# 安装依赖包
RUN set -ex && \
    apk upgrade && \
    apk add zlib pcre libssl1.1 && \
    rm -rf /var/cache/apk/*

ARG NGINX_VERSION=1.16.1
ARG WORKDIR=/usr/nginx

WORKDIR ${WORKDIR}

ENV NGINX_HTML_PATH=${WORKDIR}/html
ENV OWASP_MODSEC_CRS_PATH=${WORKDIR}/conf/owasp-modsecurity-crs

# 复制数据
COPY startup.sh dist/nginx-${NGINX_VERSION}/ ./

RUN chmod 755 startup.sh && \
    mv conf conf.example && \
    mv html html.example && \
    > .dockerenv

ARG ENABLE_MODSEC=true

COPY dist/modsecurity/ /usr
COPY dist/owasp-modsecurity-crs ./owasp-modsecurity-crs.example

RUN if [ ${ENABLE_MODSEC:-false} = true ]; then \
        sed -i "s|^prefix=.*$|prefix=/usr|g" /usr/lib/pkgconfig/modsecurity.pc; \
        sed -i "s|^# load_module.*/ngx_http_modsecurity_module.so;|load_module conf/modules/ngx_http_modsecurity_module.so;|g" conf.example/nginx.conf; \
        sed -i "s|^SecRuleEngine.*|# &\\n\\nSecRuleEngine On|g" conf.example/examples/modsec/modsecurity.conf; \
        apk add --no-cache libcurl libxml2 libstdc++ geoip; \
    fi

EXPOSE 80 443

CMD ["./startup.sh", "start"]
