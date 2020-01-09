#!/bin/bash
#
#  Author: Sky<skygangsta@hotmail.com>
# Version: 19.08.17.1
#
# Backup syslog log to local and remote server
#
#
# # 每周日凌晨 5 点备份系统日志
# 0 5 * * 0 /path/backup.sh > /dev/null 2>&1

WORK_HOME=$(cd $(dirname ${0}) && pwd)
BASE_NAME=$(basename ${0})


BACKUP_READY="false"

BACKUP_READY=`echo ${BACKUP_READY} | tr 'a-z' 'A-Z'`
if [ ${BACKUP_READY:-FALSE} = "FALSE" ]; then
    echo "Modify the script options and set BACKUP_READY=\"true\""
    exit 1
fi

#
# 以下为脚本内容
#

DATE=`date +"%Y-%m-%d"`
DATE_PATH=`date +"%Y/%m/%d"`
DATE_SUFFIX="`date +"%Y%m%d"`"

CONTAINER_ENGINE="podman"
CONTAINER_NAME="rsyslog"
SOURCE_FILES="*-${DATE_SUFFIX}"
SOURCE_COMPRESSED="true"
SOURCE_TYPE=".gz"

# 要备份的源文件
SOURCE_PATH="/home/storage/run/docker/rsyslog/logs"
# 备份保存目录
BACKUP_PATH="/home/syslog"
# 备份文件名
BACKUP_FILE="syslog-container-${DATE}"
BACKUP_TYPE=".txz"
BACKUP_ARGS="Jcf"

ENABLE_ROTATE="true"

LOCAL_BACKUP_TIME=90

ENABLE_BACKUP_SERVER="true"
# 备份服务器配置
BACKUP_SERVER_ADDR="backup-server-ip-or-host"
BACKUP_SERVER_PORT="22"
BACKUP_SERVER_USER="root"
BACKUP_SERVER_BASE="/home/backup/syslog"
BACKUP_SERVER_PATH="${BACKUP_SERVER_BASE}/${DATE_PATH}"
# 备份服务器保存时间
SERVER_BACKUP_TIME=732

func_prepare_env() {
    SOURCE_COMPRESSED=`echo ${SOURCE_COMPRESSED} | tr 'A-Z' 'a-z'`
    ENABLE_ROTATE=`echo ${ENABLE_ROTATE} | tr 'A-Z' 'a-z'`
    ENABLE_BACKUP_SERVER=`echo ${ENABLE_BACKUP_SERVER} | tr 'A-Z' 'a-z'`

    if [ ${SOURCE_COMPRESSED:-default} = "true" ]; then
        BACKUP_SERVER_PATH=${BACKUP_SERVER_PATH}/${BACKUP_FILE}
    else
        BACKUP_FILE=${BACKUP_FILE}${BACKUP_TYPE}
    fi
}

func_backup_to_server() {
    ssh ${BACKUP_SERVER_USER}@${BACKUP_SERVER_ADDR} -p ${BACKUP_SERVER_PORT} -T << EOF
        if [ ! -d ${BACKUP_SERVER_PATH} ]; then
            mkdir -p ${BACKUP_SERVER_PATH}
        fi

        # 删除服务器超过归定期限的备份
        echo "This command not enable"
        echo "find ${BACKUP_SERVER_BASE} -mtime +${SERVER_BACKUP_TIME:-3650} -type f -exec rm -rf {} \;"
        echo ""
EOF

    #将备份copy到备份服务器
    if [ ${SOURCE_COMPRESSED:-default} = "true" ]; then
        scp -P${BACKUP_SERVER_PORT} ${BACKUP_PATH}/${SOURCE_FILES}${SOURCE_TYPE} \
                ${BACKUP_SERVER_USER}@${BACKUP_SERVER_ADDR}:${BACKUP_SERVER_PATH} || exit 1
    else
        scp -P${BACKUP_SERVER_PORT} ${BACKUP_PATH}/${BACKUP_FILE} \
            ${BACKUP_SERVER_USER}@${BACKUP_SERVER_ADDR}:${BACKUP_SERVER_PATH} || exit 1
    fi

    if [ $? -eq 0 ]; then
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Backup rsyslog to server sucess."
    else
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Backup rsyslog to server failed."
    fi
}

func_backup_to_localhost() {
    if [ ! -d "${SOURCE_PATH}" ]; then
        echo -e "Source file path { ${SOURCE_PATH} } not found"
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Start backup rsyslog."
        exit 1
    fi

    if [ ! -d ${BACKUP_PATH} ]; then
        mkdir -p ${BACKUP_PATH}
    fi

    # 执行备份
    if [ ${SOURCE_COMPRESSED:-default} = "true" ]; then
        mv ${SOURCE_PATH}/${SOURCE_FILES}${SOURCE_TYPE} ${BACKUP_PATH}
    else
        tar ${BACKUP_ARGS} ${BACKUP_PATH}/${BACKUP_FILE} ${SOURCE_PATH}
    fi

    if [ $? -eq 0 ]; then
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Backup rsyslog to localhost sucess."
    else
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Backup rsyslog to localhost failed."
    fi

    # 删除本地超过归定期限的备份
    find ${BACKUP_PATH} -mtime +${LOCAL_BACKUP_TIME:-3650} -type f -exec rm -rf {} \;

    if [ $? -eq 0 ]; then
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Clean up locally expired backups sucess."
    else
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Clean up locally expired backups failed."
    fi
}

func_rotate_log_file() {
    if [ -z ${CONTAINER_NAME} ]; then
        echo "CONTAINER_NAME not set."
        exit 1
    fi

    ${CONTAINER_ENGINE} exec -it ${CONTAINER_NAME} ./startup.sh rotate

    if [ $? -eq 0 ]; then
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Rotate log file sucess."
    else
        logger -i -p info -t "${BASE_NAME}" "${WORK_HOME}/${BASE_NAME} Rotate log file failed."
        exit $?
    fi
}

func_help() {
    echo "
Usage:
    start   Start rsyslog service
    rotate  Rotate rsyslog log use logrotate
    help    Print help infomation
"
}

func_start_rsyslog() {
    func_prepare_env

    if [ ${ENABLE_ROTATE} = "true" ]; then
        func_rotate_log_file
    fi

    func_backup_to_localhost

    if [ ${ENABLE_BACKUP_SERVER} ]; then
        func_backup_to_server
    fi
}

case "$1" in
    start)
        func_start_rsyslog
        exit 0
    ;;
    rotate)
        func_rotate_log_file
        exit 0
    ;;
    *)
        func_help

        exit 1
    ;;
esac
