#!/bin/sh
#
#  Author: Ron<ronzxy@mx.aketi.cn>
# Version: v19.07.30
#
# crontab -e
#
# # Start and keep the Nginx service running
# * * * * * chmod 755 /usr/nginx/startup.sh; /usr/nginx/startup.sh start 2>&1 > /dev/null

#########################################################################
#####                                                               #####
#####                      Variable define area                     #####
#####                                                               #####
#########################################################################

WORK_HOME=$(cd $(dirname ${0}) && pwd)
BASE_NAME=$(basename ${0})

KERNEL_VERSION=`uname -r`
KERNEL_VERSION_MAJOR=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $1 ? $1 : 0}'`
KERNEL_VERSION_MINOR=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $2 ? $2 : 0}'`
KERNEL_VERSION_PATCH=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $3 ? $3 : 0}'`

# NGINX_HOME=/usr/nginx
# NGINX_CONF=${NGINX_HOME}/conf
# NGINX_HTML=${NGINX_HOME}/html
# NGINX_CERT=${NGINX_HOME}/cert
# NGINX_MODS=${NGINX_HOME}/modules
# NGINX_LOGS=${NGINX_HOME}/logs
# NGINX_TEMP=${NGINX_HOME}/temp

export LD_LIBRARY_PATH=${NGINX_HOME}/lib:$LD_LIBRARY_PATH

#########################################################################
#####                                                               #####
#####                      Function define area                     #####
#####                                                               #####
#########################################################################

function func_help() {
        echo "
Usage:
    ${BASE_NAME} [Command]

Commands:
    start       - Start nginx service
    daemon      - Start nginx service in background
    reload      - Reload nginx configuration
    test        - Test configuration
    teload      - Reload after successful test configuration
    reopen      - Reopen log files
    stop        - Stop nginx immediate
    quit        - Quit nginx until all connection close
    help        - Show this information
"
}

func_nginx_env() {
    if [ -f ${NGINX_HOME}/.dockerenv ]; then
        if [ ! -d "${NGINX_CONF}" ]; then
            mkdir -p ${NGINX_CONF}
        fi

        if [ ! -s "${NGINX_CONF}/nginx.conf" ]; then
            cp -r ${NGINX_CONF}.backup/* ${NGINX_CONF}
        fi

        if [ ! -d "${NGINX_HTML}" ]; then
            mkdir -p ${NGINX_HTML}
            cp -r ${NGINX_HTML}.backup/* ${NGINX_HTML}
        else
            # index.html
            if [ ! -f "${NGINX_HTML}/index.html" ]; then
                cp ${NGINX_HTML}.backup/index.html ${NGINX_HTML}
            fi
            # 50x.html
            if [ ! -f "${NGINX_HTML}/50x.html" ]; then
                cp ${NGINX_HTML}.backup/50x.html ${NGINX_HTML}
            fi
        fi
    fi

    chmod 755 ${NGINX_HOME}/sbin/nginx
}

function func_nginx_pids() {
    if [ -f ${NGINX_HOME}/.dockerenv ]; then
        echo $(ps -ef | grep "nginx: master process" | grep -v grep | awk -F ' ' '{print $1}')
    else
        echo $(ps -ef | grep "nginx: master process" | grep -v grep | awk -F ' ' '{print $2}')
    fi
}

function func_nginx_start() {
    func_nginx_env

    PID=$(func_nginx_pids)

    if [ "${PID:-default}" == "default" ]; then
        ${NGINX_HOME}/sbin/nginx -g "daemon off;" -p ${NGINX_HOME} -c ${NGINX_CONF}/nginx.conf
    else
        echo -e "Nginx has already started."
    fi
}

function func_nginx_daemon() {
    func_nginx_env

    PID=$(func_nginx_pids)

    if [ "${PID:-default}" == "default" ]; then
        ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_CONF}/nginx.conf
    else
        echo -e "Nginx has already started."
    fi
}

function func_nginx_reload() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_CONF}/nginx.conf -s reload
}

function func_nginx_reopen() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_CONF}/nginx.conf -s reopen
}

function func_nginx_stop() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_CONF}/nginx.conf -s stop
}

function func_nginx_quit() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_CONF}/nginx.conf -s quit
}

function func_nginx_test() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_CONF}/nginx.conf -t
}

case "$1" in
    start)
        func_nginx_start
    ;;
    daemon)
        func_nginx_daemon
    ;;
    reload)
        func_nginx_reload
    ;;
    reopen)
        func_nginx_reopen
    ;;
    stop)
        func_nginx_stop
    ;;
    quit)
        func_nginx_quit
    ;;
    restart)
        func_nginx_stop
        func_nginx_start
    ;;
    test)
        func_nginx_test
    ;;
    teload)
        func_nginx_test
        if [ $? -eq 0 ]; then
            func_nginx_reload
        fi
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

