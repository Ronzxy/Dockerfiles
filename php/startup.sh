#!/bin/sh
# Auto build php in nginx docker container
# 0 0 * * * /path/php-fpm.sh restart > /dev/null 2>&1
# */1 * * * * /path/php-fpm.sh start > /dev/null 2>&1

USER=www
GROUP=www
FPM_CONF=/etc/php/php-fpm.conf
INI_CONF=/etc/php/php.ini
PID_FILE=/var/run/php-fpm.pid

PHP_HOME=/usr/php
NGINX_HOME=/usr/nginx

PHP_CONFIG_PATH=/etc/php

# init env
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

function func_help() {
        echo "
Usage:
    ${BASE_NAME} [Command]

Commands:
    start       - Start php-fpm service
    status      - Show php-fpm master process pid
    stop        - Stop php-fpm immediate
    help        - Show this information
"
}

func_php_env() {
    for i in ${PHP_HOME}/bin/*; do
        chmod 755 ${i}
        ln -sf $i /usr/bin/`basename $i`
    done

    for i in ${PHP_HOME}/sbin/*; do
        chmod 755 ${i}
        ln -sf $i /usr/sbin/`basename $i`
    done

    for i in ${PHP_HOME}/share/*; do
        ln -sf $i /usr/share/`basename $i`
    done

    for DIR in /usr/include /usr/lib; do
        if [ ! -d ${DIR} ]; then
            mkdir -p ${DIR}
        fi
    done

    sed -i "s|\#\!.*php|\#\!/usr/bin/php|g" /usr/bin/phar

    ln -sf ${PHP_HOME}/include/php /usr/include/php
    # ln -sf ${PHP_HOME}/lib /usr/lib/php

    if [ ! -d /usr/lib/php ]; then
        mkdir -p /usr/lib/php

        for i in ${PHP_HOME}/lib/*; do
            if [ -d $i ]; then
                ln -sf $i /usr/lib/php/`basename $i`
            fi
        done
    fi

    if [ ! -d ${PHP_HOME}/log ]; then
        ln -sf /var/log ${PHP_HOME}/log
    fi

    if [ -f "${NGINX_HOME}/conf/conf.d/http/default.conf" ]; then
        # 查找 # location ~ \.php$ { 行至 # } 作为替换区域
        sed -i '/^.*# location ~ \\\.php\$ {$/,/^.*# }$/{s/# //g}' ${NGINX_HOME}/conf/conf.d/http/default.conf
    fi

    if [ "`ls -A ${PHP_CONFIG_PATH}`" = "" ]; then
        if [ ! -d ${PHP_CONFIG_PATH} ]; then
            mkdir -p ${PHP_CONFIG_PATH}
        fi

        cp -af ${PHP_HOME}/conf/* ${PHP_CONFIG_PATH}
    fi

    if [ ! -f ${NGINX_HTML_PATH}/tz.php ]; then
        if [ -d ${NGINX_HTML_PATH} ]; then
            mkdir ${NGINX_HTML_PATH}
        fi

        cp ${PHP_HOME}/tz.php ${NGINX_HTML_PATH}

        if [ ! -f ${NGINX_HTML_PATH}/index.php ]; then
            cp ${PHP_HOME}/tz.php ${NGINX_HTML_PATH}/index.php
        fi
    fi
}

function func_server_pids() {
    if [ -f ${PHP_HOME}/.dockerenv ]; then
        echo $(ps -ef | grep "php-fpm: master process" | grep -v grep | awk -F ' ' '{print $1}')
    else
        echo $(ps -ef | grep "php-fpm: master process" | grep -v grep | awk -F ' ' '{print $2}')
    fi
}

function func_server_start() {
    ${NGINX_HOME}/startup.sh daemon || exit $?

    func_php_env

    ${NGINX_HOME}/startup.sh reload || exit $?

    PID=$(func_server_pids)

    if [ -f ${PHP_HOME}/.dockerenv ]; then
        if [ "${PID:-default}" == "default" ]; then
            ${PHP_HOME}/sbin/php-fpm -F -c ${INI_CONF} -y ${FPM_CONF} -p ${PHP_HOME} -g ${PID_FILE}
        else
            echo -e "The php-fpm has already started."
        fi
    else
        if [ "${PID:-default}" == "default" ]; then
            ${PHP_HOME}/sbin/php-fpm -D -c ${INI_CONF} -y ${FPM_CONF} -p ${PHP_HOME} -g ${PID_FILE}
        else
            echo -e "The php-fpm has already started."
        fi
    fi
}

function func_server_status() {
    PID=$(func_server_pids)
    if [ "${PID:-default}" == "default" ]; then
        echo -e "The php-fpm is not running"
    else
        echo -e "The php-fpm running at ${PID}"
    fi
}

function func_server_stop() {
    ${NGINX_HOME}/startup.sh stop || exit $?

    PID=$(func_server_pids)
    if [ "${PID:-default}" == "default" ]; then
        echo -e "The php-fpm is not running"
    else
        kill ${PID}
    fi
}

case "$1" in
    start)
        func_server_start
    ;;
    status)
        func_server_status
    ;;
    stop)
        func_server_stop
    ;;
    restart)
        func_server_stop
        func_server_start
    ;;
    help)
        func_help
    ;;
    *)
        # 展示帮助信息
        func_help
        exit 1
    ;;
esac
