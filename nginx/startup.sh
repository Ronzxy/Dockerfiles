#!/bin/sh
#
# Author:  Zhang Chaoren<zhangchaoren@mx.aketi.cn>
# Version: v19.07.30
#
# crontab -e
#
# # 启动并保持 Nginx 服务持续运行
# * * * * * /usr/local/nginx/nginx.sh start 2>&1 > /dev/null

#########################################################################
#####                                                               #####
#####                      Variable define area                     #####
#####                                                               #####
#########################################################################

WORK_HOME=$(cd $(dirname ${0}) && pwd)
BASE_NAME=$(basename ${0})

# 探测cpu核心数
if [ -f /proc/cpuinfo ]; then
    j="-j$(grep 'model name' /proc/cpuinfo | wc -l || 1)"
fi

KERNEL_VERSION=`uname -r`
KERNEL_VERSION_MAJOR=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $1 ? $1 : 0}'`
KERNEL_VERSION_MINOR=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $2 ? $2 : 0}'`
KERNEL_VERSION_PATCH=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $3 ? $3 : 0}'`

NGINX_HOME=/usr/nginx

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
    reopen      - Reopen log files
    stop        - Stop nginx immediate
    quit        - Quit nginx until all connection close
    help        - Show this information
"
}

func_nginx_env() {
    if [ -f ${NGINX_HOME}/.dockerenv ]; then
        if [ ! -f "${NGINX_HOME}/conf/nginx.conf" ]; then
            if [ ! -d "${NGINX_HOME}/conf" ]; then
                mkdir -p ${NGINX_HOME}/conf
            fi

            cp -r ${NGINX_HOME}/conf.example/* ${NGINX_HOME}/conf
        fi

        if [ ! -d "${HTML_DATA_PATH}" ]; then
            if [ ! -d "${HTML_DATA_PATH}" ]; then
                mkdir -p ${HTML_DATA_PATH}
            fi

            cp -r ${NGINX_HOME}/html.example/* ${HTML_DATA_PATH}
        else
            # index.html
            if [ ! -f "${HTML_DATA_PATH}/index.html" ]; then
                cp -r ${NGINX_HOME}/html.example/index.html ${HTML_DATA_PATH}
            fi
            # 50x.html
            if [ ! -f "${HTML_DATA_PATH}/50x.html" ]; then
                cp -r ${NGINX_HOME}/html.example/50x.html ${HTML_DATA_PATH}
            fi
        fi
    fi

    # 创建目录及修改权限
    if [ ! -d /var/log/nginx ]; then
        mkdir -p /var/log/nginx
    fi

    if [ ! -d /var/cache/nginx ]; then
        mkdir -p /var/cache/nginx
    fi

    chmod 755 ${NGINX_HOME}/sbin/nginx
}

function func_server_pids() {
    if [ -f ${NGINX_HOME}/.dockerenv ]; then
        echo $(ps -ef | grep "nginx: master process" | grep -v grep | awk -F ' ' '{print $1}')
    else
        echo $(ps -ef | grep "nginx: master process" | grep -v grep | awk -F ' ' '{print $2}')
    fi
}

function func_server_start() {
    func_nginx_env

    PID=$(func_server_pids)

    if [ "${PID:-default}" == "default" ]; then
        ${NGINX_HOME}/sbin/nginx -g "daemon off;" -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf
    else
        echo -e "Nginx has already started."
    fi
}

function func_server_daemon() {
    func_nginx_env

    PID=$(func_server_pids)

    if [ "${PID:-default}" == "default" ]; then
        ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf
    else
        echo -e "Nginx has already started."
    fi
}

function func_server_reload() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf -s reload
}

function func_server_reopen() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf -s reopen
}

function func_server_stop() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf -s stop
}

function func_server_quit() {
    ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf -s quit
}

case "$1" in
    start)
        func_server_start
    ;;
    daemon)
        func_server_daemon
    ;;
    reload)
        func_server_reload
    ;;
    reopen)
        func_server_reopen
    ;;
    stop)
        func_server_stop
    ;;
    quit)
        func_server_quit
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

