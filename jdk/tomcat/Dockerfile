FROM skygangsta/jdk:8u231

ARG ZONE_NAME="Asia/Shanghai"
ARG USER=tomcat
ARG GROUP=tomcat
ARG HOME=/usr/tomcat

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
    cat /etc/passwd | grep ${USER}: || sh -c "useradd -r -u 999 -g ${GROUP} ${USER} -m -d ${HOME} -s /bin/sh" && \
    HOME=$(cat /etc/passwd | grep ${USER} | awk -F ':' '{print $6}') && \
    if [ ! -d ${HOME} ]; then mkdir -p ${HOME}; chown ${USER}:${GROUP} ${HOME}; fi && \
    apk del shadow

ARG TOMCAT_VERSION=8.5.50

ENV CATALINA_HOME=${HOME}
ENV TOMCAT_NATIVE_LIBDIR=${CATALINA_HOME}/native-jni-lib
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}${TOMCAT_NATIVE_LIBDIR}

WORKDIR ${CATALINA_HOME}

RUN set -ex && \
    TOMCAT_VERSION_MAJOR=`printf ${TOMCAT_VERSION} | awk -F '.' '{print $1}'` && \
    TOMCAT_VERSION_MINOR=`printf ${TOMCAT_VERSION} | awk -F '.' '{print $2}'` && \
    wget -c "https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
        -O apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xf apache-tomcat-${TOMCAT_VERSION}.tar.gz --strip-components=1 && \
    rm -rf bin/*.bat apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    apk upgrade && apk add libssl1.1 apr openssl-dev apr-dev build-base && \
    BUILD_TMP_DIR="$(mktemp -d)" && \
    tar xf bin/tomcat-native.tar.gz -C "${BUILD_TMP_DIR}" --strip-components=1 && \
    cd "${BUILD_TMP_DIR}/native" && \
    ./configure \
        --libdir="${TOMCAT_NATIVE_LIBDIR}" \
        --prefix="${CATALINA_HOME}" \
        --with-apr="$(command -v apr-1-config)" \
        --with-java-home="${JAVA_HOME}" \
        --with-ssl=yes && \
    make -j "$(nproc)" && \
    make install && \
    BUILD_TMP_DIR="$(mktemp -d)" && cd ${BUILD_TMP_DIR} && \
    wget -c https://fossies.org/linux/www/old/cronolog-1.6.2.tar.xz && \
    tar xf cronolog-1.6.2.tar.xz --strip-components=1 && \
    ./configure --prefix=/usr && \
    make -j "$(nproc)" && \
    make install && \
    chown -R ${USER}:${GROUP} ${CATALINA_HOME} && \
    apk del openssl-dev apr-dev build-base && \
    rm -rf /tmp/* /var/cache/apk/* ${CATALINA_HOME}/bin/tomcat-native.tar.gz

ENV CATALINA_OUT=catalina.out

VOLUME [ "${CATALINA_HOME}/conf", "${CATALINA_HOME}/logs", "${CATALINA_HOME}/webapps" ]

COPY startup.sh ./

RUN chown -R ${USER}:${GROUP} ${HOME} startup.sh && \
    chmod 755 startup.sh

USER ${USER}

EXPOSE 8080

CMD ["./startup.sh", "start"]
