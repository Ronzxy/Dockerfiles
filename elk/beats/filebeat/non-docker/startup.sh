#!/bin/sh
#
#  Author: Ron Zhang<ronzxy@mx.aketi.cn>
# Version: v2020.04.16.1
#
# Filebeat configuration startup script in non-docker
#
# # Startup filebeat in every 15 min
# */15 * * * * chmod 755 /usr/filebeat/startup.sh; /usr/filebeat/startup.sh > /dev/null 2>&1

NODE_NAME=project-1-101
ELASTICSEARCH_HOSTS=http://10.4.4.114:9200
ELASTICSEARCH_USERNAME=
ELASTICSEARCH_PASSWORD=
KIBANA_HOSTS=http://10.4.4.114:5601
SETUP_ILM_ROLLOVER_ALIAS=${NODE_NAME}
INPUT_FILE_PATTERN_LIST="'/home/business/project/trc/*/*/*/*.trc' '/home/business/project/trc/*/*.trc'"
OUTPUT_FIELDS="server: ${NODE_NAME},ip: 10.4.1.101"
FILEBEAT_HOME=/usr/filebeat

if [ ! -d "${FILEBEAT_HOME}/config" ]; then
    mkdir -p ${FILEBEAT_HOME}/config || exit $?
fi

find ${FILEBEAT_HOME}/config -maxdepth 0 -empty -exec cp -af ${FILEBEAT_HOME}/config.default/* {} \;

if [ ! -z "${NODE_NAME}" ]; then
    sed -i "s|^name:.*$|name: ${NODE_NAME}|g" ${FILEBEAT_HOME}/config/filebeat.yml
fi

if [ ! -z "${ELASTICSEARCH_HOSTS}" ]; then
    sed -i "s|^output.elasticsearch.hosts:.*$|output.elasticsearch.hosts: [${ELASTICSEARCH_HOSTS}]|g" ${FILEBEAT_HOME}/config/filebeat.yml
fi

if [ ! -z "${ELASTICSEARCH_USERNAME}" ]; then
    sed -i "s|^output.elasticsearch.username:.*$|output.elasticsearch.username: ${ELASTICSEARCH_USERNAME}|g" ${FILEBEAT_HOME}/config/filebeat.yml
fi

if [ ! -z "${ELASTICSEARCH_PASSWORD}" ]; then
    sed -i "s|^output.elasticsearch.password:.*$|output.elasticsearch.password: ${ELASTICSEARCH_PASSWORD}|g" ${FILEBEAT_HOME}/config/filebeat.yml
fi

if [ ! -z "${KIBANA_HOSTS}" ]; then
    sed -i "s|^setup.kibana.host:.*$|setup.kibana.host: ${KIBANA_HOSTS}|g" ${FILEBEAT_HOME}/config/filebeat.yml
fi

if [ ! -z "${SETUP_ILM_ROLLOVER_ALIAS}" ]; then
    sed -i "s|^setup.ilm.rollover_alias:.*$|setup.ilm.rollover_alias: ${SETUP_ILM_ROLLOVER_ALIAS}|g" ${FILEBEAT_HOME}/config/filebeat.yml
fi

if [ ! -z "${INPUT_FILE_PATTERN_LIST}" ]; then
    sed -i "/^- type: log$/,/^[ ]*enabled:.*/{s/^[ ]*enabled:.*$/  enabled: true/g}" ${FILEBEAT_HOME}/config/filebeat.yml
set -ex
    INPUT_FILE_PATTERN_LIST=${INPUT_FILE_PATTERN_LIST//,/ }
    for FILE_PATTERN in ${INPUT_FILE_PATTERN_LIST}
    do
        grep -Fq "${FILE_PATTERN}" ${FILEBEAT_HOME}/config/filebeat.yml || \
            sed -i "/^- type: log$/,/^[ ]*multiline.pattern:.*/{s|^[ ]*paths:$|&\\n    - ${FILE_PATTERN}|g}" ${FILEBEAT_HOME}/config/filebeat.yml
    done
fi

if [ ! -z "${OUTPUT_FIELDS}" ]; then
    sed -i '/^#fields:.*$/,/^#[ ]*env:.*$/{s/#//g}' ${FILEBEAT_HOME}/config/filebeat.yml
    IFS=','
    for FIELD in ${OUTPUT_FIELDS}
    do
        grep -Fq "${FIELD}" ${FILEBEAT_HOME}/config/filebeat.yml || \
            sed -i "/^fields:.*$/,/^[ ]*env:.*$/{s|^fields:.*$|&\\n  ${FIELD}|g}" ${FILEBEAT_HOME}/config/filebeat.yml
    done
fi

chown -R `id -u`:`id -g` ${FILEBEAT_HOME}/config || exit $?

${FILEBEAT_HOME}/filebeat -c ${FILEBEAT_HOME}/config/filebeat.yml -e \
    --path.home ${FILEBEAT_HOME} \
    --path.data ${FILEBEAT_HOME}/data \
    --path.logs ${FILEBEAT_HOME}/logs \
    --path.config ${FILEBEAT_HOME}/config
