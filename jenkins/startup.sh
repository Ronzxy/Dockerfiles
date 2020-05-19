#!/bin/sh
#
#  Author: Zhang Chaoren<zhangchaoren@mx.aketi.cn>
# Version: v19.08.23.1
#
# PostgreSQL initial and start up, support docker

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

func_start() {
    java ${JAVA_OPTS} -jar ${WORK_HOME}/jenkins.war --httpPort=${JENKINS_HTTP_PORT}
}

func_stop() {
    pkill java
}

func_reload() {
    echo "Reload - Not implemented"
}

func_help() {
    echo "
Usage:
    start       - Start postgres service
    reload      - Reload postgres
    stop        - Fast stop postgres service. And smart,immediate available
    restart     - Restart postgres service.
    help        - Print help infomation
"
}

case "$1" in
    start)
        func_start
        
        exit 0
    ;;
    reload)
        func_reload

        exit 0
    ;;
    stop)
        func_stop $2

        exit 0
    ;;
    restart)
        func_stop
        sleep 1
        func_start

        exit 0
    ;;
    help)
        func_help
        
        exit 0
    ;;
    *)
        func_help

        exit 1
    ;;
esac
