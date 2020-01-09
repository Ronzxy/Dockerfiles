#!/bin/sh

WORK_HOME=$(cd $(dirname ${0}) && pwd)
BASE_NAME=$(basename ${0})

if [ ! -f ${WORK_HOME}/config.yml ]; then
    ln -sf /usr/bin/python3 /usr/bin/python
    ln -sf /usr/bin/pip3 /usr/bin/pip
    cp -f ${WORK_HOME}/config_example.yml  ${WORK_HOME}/config.yml

    if [ -z ${SECRET_KEY} ]; then
        SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`
    fi

    if [ -z ${BOOTSTRAP_TOKEN} ]; then
        BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`
    fi

    sed -i "s/SECRET_KEY:/SECRET_KEY: ${SECRET_KEY}/g" ${WORK_HOME}/config.yml
    sed -i "s/BOOTSTRAP_TOKEN:/BOOTSTRAP_TOKEN: ${BOOTSTRAP_TOKEN}/g" ${WORK_HOME}/config.yml
    sed -i "s/# DEBUG: true/DEBUG: ${DEBUG}/g" ${WORK_HOME}/config.yml
    sed -i "s/# LOG_LEVEL: DEBUG/LOG_LEVEL: ${LOG_LEVEL}/g" ${WORK_HOME}/config.yml
    sed -i "s/# SESSION_EXPIRE_AT_BROWSER_CLOSE: false/SESSION_EXPIRE_AT_BROWSER_CLOSE: true/g" ${WORK_HOME}/config.yml

    sed -i "s/^DB_ENGINE:.*/DB_ENGINE: ${DB_ENGINE}/g" ${WORK_HOME}/config.yml
    sed -i "s/^DB_HOST:.*/DB_HOST: ${DB_HOST}/g" ${WORK_HOME}/config.yml
    sed -i "s/^DB_PORT:.*/DB_PORT: ${DB_PORT}/g" ${WORK_HOME}/config.yml
    sed -i "s/^DB_NAME:.*/DB_NAME: ${DB_NAME}/g" ${WORK_HOME}/config.yml
    sed -i "s/^DB_USER:.*/DB_USER: ${DB_USER}/g" ${WORK_HOME}/config.yml
    sed -i "s/^DB_PASSWORD:.*/DB_PASSWORD: ${DB_PASSWORD}/g" ${WORK_HOME}/config.yml

    sed -i "s/^REDIS_HOST:.*/REDIS_HOST: ${REDIS_HOST}/g" ${WORK_HOME}/config.yml
    sed -i "s/^REDIS_PORT:.*/REDIS_PORT: ${REDIS_PORT}/g" ${WORK_HOME}/config.yml
    
    if [ ! -z ${REDIS_PASSWORD} ]; then
        sed -i "s/^.*REDIS_PASSWORD:.*/REDIS_PASSWORD: ${REDIS_PASSWORD}/g" ${WORK_HOME}/config.yml
    fi

    if [ ! -z ${REDIS_DB_CELERY} ]; then
        sed -i "s/^.*REDIS_DB_CELERY:.*/REDIS_DB_CELERY: ${REDIS_DB_CELERY}/g" ${WORK_HOME}/config.yml
    fi

    if [ ! -z ${REDIS_DB_CACHE} ]; then
        sed -i "s/^.*REDIS_DB_CACHE:.*/REDIS_DB_CACHE: ${REDIS_DB_CACHE}/g" ${WORK_HOME}/config.yml
    fi

    echo -e "\033[31m 你的SECRET_KEY是 $SECRET_KEY \033[0m"
    echo -e "\033[31m 你的BOOTSTRAP_TOKEN是 $BOOTSTRAP_TOKEN \033[0m"
fi

if [ ! -d ${WORK_HOME}/data/luna ]; then
    cp -af ${WORK_HOME}/luna ${WORK_HOME}/data/luna
fi

if [ ! -f ${WORK_HOME}/data/jumpserver.conf ]; then
    cp -af ${WORK_HOME}/jumpserver.conf ${WORK_HOME}/data
fi

chown -R jumpserver:jumpserver ${WORK_HOME}

su - jumpserver -c "${WORK_HOME}/jms start"

