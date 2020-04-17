#!/bin/bash

if [ "`ls -A ${HOME}/config`" = "" ]; then
    cp -af ${HOME}/config.default/* ${HOME}/config
fi

if [ ! -z ${DISCOVERY_TYPE} ]; then
    grep "discovery.type:.*" config/elasticsearch.yml || \
        echo "discovery.type: ${DISCOVERY_TYPE}" >> config/elasticsearch.yml
fi

if [ ! -z ${DISCOVERY_SEED_HOSTS} ]; then
    grep "discovery.seed_hosts:.*" config/elasticsearch.yml || \
        echo "discovery.seed_hosts: ${DISCOVERY_SEED_HOSTS}" >> config/elasticsearch.yml
fi

bin/elasticsearch
