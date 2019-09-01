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
使用方法:
    ${BASE_NAME} [命令]

支持的命令:
    start       启动并保持 Nginx 服务持续运行
    reload      重新加载 Nginx 配置文件
    reopen      重新打开日志文件
    stop        立即关闭 Nginx 不等待所有连接关闭
    quit        退出 Nginx 并等待所有连接关闭
    help        展示 ${BASE_NAME} 脚本的帮助信息
"
}

func_nginx_env() {
    if [ -f .dockerenv ]; then
        if [ ! -f "${NGINX_HOME}/conf/nginx.conf" ]; then
            if [ ! -d "${NGINX_HOME}/conf" ]; then
                mkdir -p ${NGINX_HOME}/conf
            fi

            cp -r ${NGINX_HOME}/conf.example/* ${NGINX_HOME}/conf
        fi

        if [ ! -d "${NGINX_HOME}/html" ]; then
            if [ ! -d "${NGINX_HOME}/html" ]; then
                mkdir -p ${NGINX_HOME}/html
            fi

            cp -r ${NGINX_HOME}/html.example/* ${NGINX_HOME}/html
        else
            # index.html
            if [ ! -f "${NGINX_HOME}/html/index.html" ]; then
                cp -r ${NGINX_HOME}/html.example/index.html ${NGINX_HOME}/html
            fi
            # 50x.html
            if [ ! -f "${NGINX_HOME}/html/50x.html" ]; then
                cp -r ${NGINX_HOME}/html.example/50x.html ${NGINX_HOME}/html
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
}

function func_server_start() {
    func_nginx_env

    if [ -f .dockerenv ]; then
        PID=$(ps -ef | grep "${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf" | grep -v grep | awk -F ' ' '{print $1}')
        if [ "${PID:-default}" == "default" ]; then
            ${NGINX_HOME}/sbin/nginx -g "daemon off;" -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf
        else
            echo -e "Nginx has already started."
        fi
    else
        PID=$(ps -ef | grep "${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf" | grep -v grep | awk -F ' ' '{print $2}')
        if [ "${PID:-default}" == "default" ]; then
            ${NGINX_HOME}/sbin/nginx -p ${NGINX_HOME} -c ${NGINX_HOME}/conf/nginx.conf
        else
            echo -e "Nginx has already started."
        fi
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

