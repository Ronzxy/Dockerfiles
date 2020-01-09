#!/bin/sh

if [ "`ls -A ${HOME}/config`" = "" ]; then
    cp -af ${HOME}/config.default/* ${HOME}/config
fi


if [ ! -z ${SERVER_NAME} ]; then
    sed -i "s/server.name:.*/server.name: ${SERVER_NAME}/g" config/kibana.yml
fi

if [ ! -z ${SERVER_HOST} ]; then
    sed -i "s/server.host:.*/server.host: ${SERVER_HOST}/g" config/kibana.yml
fi

if [ ! -z ${ELASTICSEARCH_HOSTS} ]; then
    sed -i "s|elasticsearch.hosts:.*|elasticsearch.hosts: [ \"${ELASTICSEARCH_HOSTS}\" ]|g" config/kibana.yml
fi

if [ ! -z ${ELASTICSEARCH_HOSTS} ]; then
    sed -i "s|path.data:.*|path.data: ${HOME}/data|g" config/kibana.yml
fi

if [ ! -z ${XPACK_REPORTING_ENABLED} ]; then
    sed -i "s/xpack.reporting.enabled:.*/xpack.reporting.enabled: ${XPACK_REPORTING_ENABLED}/g" config/kibana.yml
fi

sh ${HOME}/bin/kibana
