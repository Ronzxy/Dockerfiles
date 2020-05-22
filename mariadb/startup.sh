#!/bin/sh
#
#  Author: Ron Zhang <ronzxy@mx.aketi.cn>
# Version: v20.05.21.1
#
# MariaDB initial and start up, support docker

WORK_HOME=$(cd $(dirname ${0}) && pwd)
BASE_NAME=$(basename ${0})

KERNEL_VERSION=`uname -r`
KERNEL_VERSION_MAJOR=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $1 ? $1 : 0}'`
KERNEL_VERSION_MINOR=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $2 ? $2 : 0}'`
KERNEL_VERSION_PATCH=`printf ${KERNEL_VERSION:-0.0.0} | awk -F '.' '{print $3 ? $3 : 0}'`

USER=$(cat /.dockerenv | grep USER | awk -F '=' '{print $2}')
GROUP=$(cat /.dockerenv | grep GROUP | awk -F '=' '{print $2}')

USER=${USER:-mysql}
GROUP=${GROUP:-mysql}

func_init() {
    mysql_install_db --user=${USER} --datadir=${MYSQL_DATA_PATH} > /dev/null || exit $?

    if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
		MYSQL_ROOT_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`
		echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
	fi

    TMP_FILE="$(mktemp)"
    cat > ${TMP_FILE} <<EOF
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL ON *.* TO 'root'@'%' identified by '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF
    mysqld --user=${USER} --datadir=${MYSQL_DATA_PATH} --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < ${TMP_FILE}
    rm -rf ${TMP_FILE}
}

func_start() {
    if [ -z "`ls ${MYSQL_DATA_PATH}`" ]; then
        func_init
    fi

    exec /usr/bin/mysqld_safe --user=${USER} --datadir=${MYSQL_DATA_PATH} --skip-name-resolve --skip-networking=0 $@
}

func_stop() {
    /usr/bin/mysqladmin shutdown -p
}

func_reload() {
    /usr/bin/mysqladmin reload -p
}

func_help() {
    echo "
Usage:
    start       - Start mariadb service
    reload      - Reload mariadb
    stop        - Fast stop mariadb service. And smart,immediate available
    restart     - Restart mariadb service.
    help        - Print help infomation
"
}

# 检查是否为 root 用户
if [ "$(id -u)" != "0" ]; then
    echo "Error: Please use the root user to execute this shell."
    exit 1
fi

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
