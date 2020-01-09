#!/bin/sh

if [ "`ls -A ${HOME}/config`" = "" ]; then
    cp -af ${HOME}/config.default/* ${HOME}/config
fi

if [ ! -z ${NODE_NAME} ]; then
    sed -i "s|# node.name:|node.name: ${NODE_NAME}|g" ${HOME}/config/logstash.yml
    sed -i "s|node.name:.*|node.name: ${NODE_NAME}|g" ${HOME}/config/logstash.yml
fi

if [ ! -z ${LOGSTASH_DATA} ]; then
    sed -i "s|# path.data:|path.data: ${LOGSTASH_DATA}|g" ${HOME}/config/logstash.yml
    sed -i "s|path.data:.*|path.data: ${LOGSTASH_DATA}|g" ${HOME}/config/logstash.yml
fi

if [ ! -d ${LOGSTASH_DATA} ]; then
    mkdir -p ${LOGSTASH_DATA}
fi

if [ ! -f ${HOME}/config/logstash.conf ]; then
    cp ${HOME}/config/logstash-sample.conf ${HOME}/config/logstash.conf

    sed -i "/^[ ]*elasticsearch {$/,/^[ ][ ]*}/{s|hosts => \[\".*\"\]|hosts => \[\"${ELASTICSEARCH_HOSTS}\"\]|g}}" ${HOME}/config/logstash.conf
fi

sh ${HOME}/bin/logstash -f ${HOME}/config/logstash.conf
