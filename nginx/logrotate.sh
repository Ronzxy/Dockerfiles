#!/bin/sh
#
#  Author: Ron<ronzxy@mx.aketi.cn>
# Version: v20.04.25.1
# 
# Rotate the nginx log
#
# crontab -e
#
# # 每天0点0分0秒启动备份Nginx日志
# 0 0 * * * chmod 755 /usr/scripts/logrotate.sh; /usr/scripts/logrotate.sh > /usr/scripts/logrotate.log 2>&1

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

NGINX_LOGS="/var/lib/docker/volumes/nginx-logs/_data"

CONTAINER_ENGINE=docker
CONTAINER_NAME=nginx

TAR_OPT="Jcvf"
TAR_EXT="txz"

BACKUP_PATH=/usr/backup

DATE_DAY=1
if [ ! -z "${1}" ]; then
    DATE_DAY=${1}
fi

DATE_NAME="nginx-`date +"%Y-%m-%d" -d "-${DATE_DAY} days"`"
DATE_PATH="`date +"%Y/%m/%d" -d "-${DATE_DAY} days"`"

if [ ! -d ${NGINX_LOGS}/${DATE_NAME} ]; then
    mkdir -p ${NGINX_LOGS}/${DATE_NAME} || exit $?
    mv ${NGINX_LOGS}/*.log ${NGINX_LOGS}/${DATE_NAME}
    ${CONTAINER_ENGINE} exec ${CONTAINER_NAME} startup.sh reopen
fi

if [ ! -d ${BACKUP_PATH}/${DATE_PATH} ]; then
    mkdir -p ${BACKUP_PATH}/${DATE_PATH} || exit 1
fi

tar ${TAR_OPT} ${BACKUP_PATH}/${DATE_PATH}/${DATE_NAME}.${TAR_EXT} -C ${NGINX_LOGS} ${DATE_NAME} || exit 1
rm -rf ${NGINX_LOGS}/${DATE_NAME}
