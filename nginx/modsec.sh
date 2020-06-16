#!/bin/sh
#
#  Author: Ron<ronzxy@mx.aketi.cn>
# Version: v20.06.16

WORK_HOME=$(cd $(dirname ${0}) && pwd)
BASE_NAME=$(basename ${0})

NGINX_CONF=/usr/nginx/conf
NGINX_LOGS=/usr/nginx/logs

func_help() {
        echo "
Usage:
    ${BASE_NAME} [Command]

Commands:
    create      - Create a modsecurity configuration with the given domain name, the default is 'localhost'
    help        - Show this information
"
}

func_create() {
    DOMAIN_NAME=${1}
    if [ -z "${DOMAIN_NAME}" ]; then
        DOMAIN_NAME=localhost
    fi

    if [ -d "${WORK_HOME}/${DOMAIN_NAME}" ]; then
        echo "${WORK_HOME}/${DOMAIN_NAME} already exists"
        exit 1
    fi

    mkdir -p "${WORK_HOME}/${DOMAIN_NAME}"

    cp -af ${WORK_HOME}/../../examples/modsec/* ${WORK_HOME}/${DOMAIN_NAME}

    echo "#    modsecurity on;" >> ${WORK_HOME}/${DOMAIN_NAME}/main.conf
    echo "#    modsecurity_rules_file ${NGINX_CONF}/conf.d/modsec/${DOMAIN_NAME}/main.conf;" >> ${WORK_HOME}/${DOMAIN_NAME}/main.conf
    echo "" >> ${WORK_HOME}/${DOMAIN_NAME}/main.conf
    echo "Include ${NGINX_CONF}/conf.d/modsec/${DOMAIN_NAME}/modsecurity.conf" >> ${WORK_HOME}/${DOMAIN_NAME}/main.conf
    echo "Include ${NGINX_CONF}/conf.d/modsec/${DOMAIN_NAME}/owasp-modsecurity-crs/crs-setup.conf" >> ${WORK_HOME}/${DOMAIN_NAME}/main.conf
    echo "Include ${NGINX_CONF}/conf.d/modsec/${DOMAIN_NAME}/owasp-modsecurity-crs/rules/*.conf" >> ${WORK_HOME}/${DOMAIN_NAME}/main.conf
    sed -i "s|SecAuditLog.*|SecAuditLog ${NGINX_LOGS}/${DOMAIN_NAME}_modsec_audit.log|g" ${WORK_HOME}/${DOMAIN_NAME}/modsecurity.conf
    sed -i "s/SecDefaultAction \"phase:1,log,auditlog,pass\"/SecDefaultAction \"phase:1,log,auditlog,deny,status:403\"/g" ${WORK_HOME}/${DOMAIN_NAME}/owasp-modsecurity-crs/crs-setup.conf
    sed -i "s/SecDefaultAction \"phase:2,log,auditlog,pass\"/SecDefaultAction \"phase:2,log,auditlog,deny,status:403\"/g" ${WORK_HOME}/${DOMAIN_NAME}/owasp-modsecurity-crs/crs-setup.conf
}

case "$1" in
    create)
        func_create $2
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
