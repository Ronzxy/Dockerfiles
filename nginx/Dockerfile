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
    rm -rf /tmp/* /var/cache/apk/*

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=www
ARG GROUP=www

RUN set -ex; \
    apk add --no-cache shadow tzdata; \
    # 初始化时区
    cp /usr/share/zoneinfo/${ZONE_NAME} /etc/localtime && echo "Asia/Shanghai" > /etc/timezone; \
    # 初始化用户信息，将生产用户gid和uid与docker一致
    cat /etc/group | grep :999: | awk -F ':' '{print "groupmod -g 1999 "$1}' | sh; \
    cat /etc/passwd | grep :999: | awk -F ':' '{print "usermod -u 1999 "$1}' | sh; \
    cat /etc/group | grep ${GROUP}: | awk -F ':' '{print "groupmod -g 999 "$1}' | sh; \
    cat /etc/passwd | grep ${USER}: | awk -F ':' '{print "usermod -u 999 "$1}' | sh; \
    cat /etc/group | grep ${GROUP}: || sh -c "groupadd -r -g 999 ${GROUP}"; \
    cat /etc/passwd | grep ${USER}: || sh -c "useradd -r -u 999 -g ${GROUP} ${USER} -m -d /home/${USER} -s /bin/sh"; \
    HOME=$(cat /etc/passwd | grep www | awk -F ':' '{print $6}'); \
    if [ ! -d ${HOME} ]; then mkdir -p ${HOME}; fi; \
    apk del --no-cache --purge shadow tzdata; \
    rm -rf /tmp/* /var/cache/apk/*

ARG WORKDIR=/usr/nginx
ARG NGINX_VERSION=1.16.1
ARG STICKY_VERSION=1.2.6
ARG ENABLE_MODSEC=YES
ARG MODSEC_BRANCH=v3/master
ARG OWASP_MODSEC_CRS_VERSION=3.2.0

WORKDIR ${WORKDIR}

ENV NGINX_HOME=${WORKDIR}
ENV NGINX_CONF=${WORKDIR}/conf
ENV NGINX_HTML=${WORKDIR}/html
ENV NGINX_CERT=${WORKDIR}/cert
ENV NGINX_MODS=${WORKDIR}/modules
ENV NGINX_LOGS=${WORKDIR}/logs
ENV NGINX_TEMP=${WORKDIR}/temp

RUN set -ex; \
    WORK_HOME="$(mktemp -d)" && cd ${WORK_HOME}; \
    if [ ${ENABLE_MODSEC:-NO} = YES ]; then \
        apk add --no-cache coreutils zlib pcre libssl1.1 libxslt libcurl libxml2 libstdc++ geoip \
            build-base git automake autoconf patch libtool pcre-dev zlib-dev openssl-dev libxslt-dev linux-headers libxml2-dev curl-dev geoip-dev; \

        git clone --depth 1 -b ${MODSEC_BRANCH} --single-branch https://github.com/SpiderLabs/ModSecurity \
            ${WORK_HOME}/modsecurity; \
        git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git \
            ${WORK_HOME}/modsecurity-nginx; \
        wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${OWASP_MODSEC_CRS_VERSION}.tar.gz \
            -O ${WORK_HOME}/owasp-modsecurity-crs-${OWASP_MODSEC_CRS_VERSION}.tar.gz; \
        git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/src/${STICKY_VERSION}/ \
            ${WORK_HOME}/nginx-sticky-module-${STICKY_VERSION}; \
        wget https://github.com/itoffshore/nginx-upstream-fair/archive/master.tar.gz \
            -O ${WORK_HOME}/nginx-upstream-fair-master.tar.gz; \
        wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
            -O ${WORK_HOME}/nginx-${NGINX_VERSION}.tar.gz; \
        cd ${WORK_HOME}/modsecurity; \
        git submodule init; \
        git submodule update; \
        chmod 755 ./build.sh; \
        ./build.sh; \
        chmod 755 ./configure; \
        ./configure --prefix=/usr; \
        make -j "$(nproc)"; \
        make install; \
        DYNAMIC_MODULE_ADDON="--add-dynamic-module=${WORK_HOME}/modsecurity-nginx"; \
    else \
        # 不编译
        apk add --no-cache coreutils zlib pcre libssl1.1 libxslt \
            build-base git automake autoconf patch libtool pcre-dev zlib-dev openssl-dev libxslt-dev linux-headers; \
        git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/src/${STICKY_VERSION}/ \
            ${WORK_HOME}/nginx-sticky-module-${STICKY_VERSION}; \
        wget https://github.com/itoffshore/nginx-upstream-fair/archive/master.tar.gz \
            -O ${WORK_HOME}/nginx-upstream-fair-master.tar.gz; \
        wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
            -O ${WORK_HOME}/nginx-${NGINX_VERSION}.tar.gz; \
    fi; \
    tar xf ${WORK_HOME}/nginx-upstream-fair-master.tar.gz -C ${WORK_HOME};\
    tar xf ${WORK_HOME}/nginx-${NGINX_VERSION}.tar.gz -C ${WORK_HOME}; \
        cd ${WORK_HOME}/nginx-${NGINX_VERSION}; \
    ./configure --prefix=${NGINX_HOME} \
    --sbin-path=${NGINX_HOME}/sbin/nginx \
    --conf-path=${NGINX_CONF}/nginx.conf \
    --modules-path=${NGINX_MODS} \
    --error-log-path=${NGINX_LOGS}/error.log \
    --http-log-path=${NGINX_LOGS}/access.log \
    --pid-path=${NGINX_TEMP}/nginx.pid \
    --lock-path=${NGINX_TEMP}/nginx.lock \
    --http-client-body-temp-path=${NGINX_TEMP}/body \
    --http-proxy-temp-path=${NGINX_TEMP}/proxy \
    --http-fastcgi-temp-path=${NGINX_TEMP}/fastcgi \
    --http-uwsgi-temp-path=${NGINX_TEMP}/uwsgi \
    --http-scgi-temp-path=${NGINX_TEMP}/scgi \
    --user=www --group=www \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-cpp_test_module \
    --with-debug \
    --with-threads \
    --with-compat \
    --with-cc-opt='-O2 -g -m64 -mtune=generic' \
    --add-module=${WORK_HOME}/nginx-sticky-module-${STICKY_VERSION} \
    --add-dynamic-module=${WORK_HOME}/nginx-upstream-fair-master ${DYNAMIC_MODULE_ADDON}; \
    make -j "$(nproc)"; \
    make install; \
    cd ${NGINX_CONF}; \
    cp fastcgi.conf fastcgi.conf.default; \
    cp fastcgi_params fastcgi_params.default; \
    cp koi-utf koi-utf.default; \
    cp koi-win koi-win.default; \
    cp mime.types mime.types.default; \
    cp nginx.conf nginx.conf.default; \
    cp scgi_params scgi_params.default; \
    cp uwsgi_params uwsgi_params.default; \
    cp win-utf win-utf.default; \
    # 清理编译工具及编译依赖并再次确认依赖包
    if [ ${ENABLE_MODSEC:-NO} = YES ]; then \
        mkdir -p ${NGINX_CONF}/examples/modsec; \
        cp ${WORK_HOME}/modsecurity/modsecurity.conf-recommended ${NGINX_CONF}/examples/modsec/modsecurity.conf; \
        cp ${WORK_HOME}/modsecurity/unicode.mapping ${NGINX_CONF}/examples/modsec; \
        cp ${WORK_HOME}/nginx-${NGINX_VERSION}/objs/ngx_http_modsecurity_module.so ${NGINX_CONF}/modules; \
        tar xf ${WORK_HOME}/owasp-modsecurity-crs-${OWASP_MODSEC_CRS_VERSION}.tar.gz -C ${WORK_HOME}; \
        mv ${WORK_HOME}/owasp-modsecurity-crs-${OWASP_MODSEC_CRS_VERSION} ${NGINX_CONF}/owasp-modsecurity-crs; \
        apk del --no-cache --purge build-base git automake autoconf patch libtool pcre-dev zlib-dev openssl-dev libxslt-dev linux-headers libxml2-dev curl-dev geoip-dev; \
        apk add --no-cache zlib pcre libssl1.1 libxslt libcurl libxml2 libstdc++ geoip; \
    else \
        apk del --no-cache --purge build-base git automake autoconf patch libtool pcre-dev zlib-dev openssl-dev libxslt-dev linux-headers; \
        apk add --no-cache zlib pcre libssl1.1 libxslt; \
    fi; \
    # 清理数据
    rm -rf /tmp/* /var/cache/apk/*

# ###
# # 复制数据
COPY startup.sh conf ./

RUN set -ex; \
    chmod 755 startup.sh; \
    cp -af ./conf.d ./examples ./nginx.conf ${NGINX_CONF}; rm -rf ./conf.d ./examples ./nginx.conf; \
    if [ ${ENABLE_MODSEC:-NO} = YES ]; then \
        sed -i "s|^prefix=.*$|prefix=/usr|g" /usr/lib/pkgconfig/modsecurity.pc; \
        sed -i "s|^# load_module.*/ngx_http_modsecurity_module.so;|load_module ${NGINX_MODS}/ngx_http_modsecurity_module.so;|g" ${NGINX_CONF}/nginx.conf; \
        sed -i "s|^SecRuleEngine.*|# &\\n\\nSecRuleEngine On|g" ${NGINX_CONF}/examples/modsec/modsecurity.conf; \
        echo "#     modsecurity on;" >> ${NGINX_CONF}/examples/modsec/main.conf; \
        echo "#     modsecurity_rules_file /usr/nginx/conf/conf.d/modsec/main.conf;" >> ${NGINX_CONF}/examples/modsec/main.conf; \
        echo "" >> ${NGINX_CONF}/examples/modsec/main.conf; \
        echo "Include /usr/nginx/conf/conf.d/modsec/modsecurity.conf" >> ${NGINX_CONF}/examples/modsec/main.conf; \
        echo "Include /usr/nginx/conf/owasp-modsecurity-crs/crs-setup.conf" >> ${NGINX_CONF}/examples/modsec/main.conf; \
        echo "Include /usr/nginx/conf/owasp-modsecurity-crs/rules/*.conf" >> ${NGINX_CONF}/examples/modsec/main.conf; \
    fi; \
    cp -af ${NGINX_CONF} ${NGINX_CONF}.backup; \
    cp -af ${NGINX_HTML} ${NGINX_HTML}.backup; \
    > .dockerenv

VOLUME [ "${NGINX_CONF}", "${NGINX_HTML}", "${NGINX_CERT}", "${NGINX_MODS}", "${NGINX_LOGS}", "${NGINX_TEMP}" ]

EXPOSE 80 443

CMD ["./startup.sh", "start"]
