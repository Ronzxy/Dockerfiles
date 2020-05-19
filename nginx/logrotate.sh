#!/bin/sh
#
#  Author: Ron<ronzxy@mx.aketi.cn>
# Version: v20.04.25.1
# 
# Rotate the Nginx logs
#
# crontab -e
#
# # Rotate the Nginx logs at 00:00:00 every day
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
# NGINX_LOGS="/var/lib/containers/storage/volumes/nginx-logs/_data"

CONTAINER_ENGINE=docker
CONTAINER_NAME=nginx

IP_ADDR=`/usr/sbin/ip addr | grep 172.31 | awk -F ' ' '{print $2}' | awk -F '/' '{print $1}'`

TAR_OPT="Jcvf"
TAR_EXT="txz"

BACKUP_PATH="/usr/backup"

BACKUP_SAVE_TIME=30

REMOTE_HOST=localhost

DATE_DAY=1
if [ ! -z "${1}" ]; then
    DATE_DAY=${1}
fi

DATE_NAME="${IP_ADDR}-`date +"%Y-%m-%d" -d "-${DATE_DAY} days"`-nginx"
DATE_PATH="`date +"%Y/%m/%d" -d "-${DATE_DAY} days"`"

${CONTAINER_ENGINE} ps | grep ${CONTAINER_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    # Container is not running, do something
    exit 1
fi

if  [ ! -f ${BACKUP_PATH}/${DATE_PATH}/${DATE_NAME}.${TAR_EXT} ] && \
    [ ! -d ${NGINX_LOGS}/${DATE_NAME} ]; then

    mkdir -p ${NGINX_LOGS}/${DATE_NAME} || exit $?
    mv ${NGINX_LOGS}/*.log ${NGINX_LOGS}/${DATE_NAME}
    ${CONTAINER_ENGINE} exec ${CONTAINER_NAME} ./startup.sh reopen
else
    if  [ -f ${BACKUP_PATH}/${DATE_PATH}/${DATE_NAME}.${TAR_EXT} ]; then
        echo "[$(env LANG=en_US.UTF-8 date +'%a, %d %b %Y %T %z')] - ERROR - ${BACKUP_PATH}/${DATE_PATH}/${DATE_NAME}.${TAR_EXT} already exists"
        exit 1
    fi
fi

if [ ! -d ${BACKUP_PATH}/${DATE_PATH} ]; then
    mkdir -p ${BACKUP_PATH}/${DATE_PATH} || exit 1
fi

if  [ -d ${NGINX_LOGS}/${DATE_NAME} ]; then

    tar ${TAR_OPT} ${BACKUP_PATH}/${DATE_PATH}/${DATE_NAME}.${TAR_EXT} -C ${NGINX_LOGS} ${DATE_NAME} || exit 1
    rm -rf ${NGINX_LOGS}/${DATE_NAME}
else
    echo "[$(env LANG=en_US.UTF-8 date +'%a, %d %b %Y %T %z')] - ERROR - ${NGINX_LOGS}/${DATE_NAME} does not exists"
    exit 1
fi

# Delete expired log backups
find ${BACKUP_PATH} -mtime +${BACKUP_SAVE_TIME:-90} -type f -exec rm -rf {} \;

# # Send local backup to remote server
# rsync -aAHXvc -z --compress-level=9 \
#     --password-file=/etc/rsync.d/data.password \
#     ${BACKUP_PATH} data@${REMOTE_HOST}::backup
