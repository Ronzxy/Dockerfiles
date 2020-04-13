#!/bin/sh

if [ "`ls -A ${HOME}/config`" = "" ]; then
    cp -af ${HOME}/config.default/* ${HOME}/config
fi

if [ ! -z "${NODE_NAME}" ]; then
    sed -i "s|^name:.*$|name: ${NODE_NAME}|g" ${HOME}/config/filebeat.yml
fi

if [ ! -z "${ELASTICSEARCH_HOSTS}" ]; then
    sed -i "s|^output.elasticsearch.hosts:.*$|output.elasticsearch.hosts: [${ELASTICSEARCH_HOSTS}]|g" ${HOME}/config/filebeat.yml
fi

if [ ! -z "${ELASTICSEARCH_USERNAME}" ]; then
    sed -i "s|^output.elasticsearch.username:.*$|output.elasticsearch.username: ${ELASTICSEARCH_USERNAME}|g" ${HOME}/config/filebeat.yml
fi

if [ ! -z "${ELASTICSEARCH_PASSWORD}" ]; then
    sed -i "s|^output.elasticsearch.password:.*$|output.elasticsearch.password: ${ELASTICSEARCH_PASSWORD}|g" ${HOME}/config/filebeat.yml
fi

if [ ! -z "${KIBANA_HOSTS}" ]; then
    sed -i "s|^setup.kibana.host:.*$|setup.kibana.host: ${KIBANA_HOSTS}|g" ${HOME}/config/filebeat.yml
fi

if [ ! -z "${SETUP_ILM_ROLLOVER_ALIAS}" ]; then
    sed -i "s|^setup.ilm.rollover_alias:.*$|setup.ilm.rollover_alias: ${SETUP_ILM_ROLLOVER_ALIAS}|g" ${HOME}/config/filebeat.yml
fi

if [ -z "${SETUP_ILM_OVERWRITE}" ]; then
    SETUP_ILM_OVERWRITE=false
fi

if [ `echo ${SETUP_ILM_OVERWRITE} | tr 'A-Z' 'a-z'` = 'true' ]; then
    sed -i '/^.*# setup.ilm.policy_name:.*$/,/# setup.ilm.overwrite:.*$/{s/# //g}' ${HOME}/config/filebeat.yml

    sed -i "s|^setup.ilm.overwrite:.*$|setup.ilm.overwrite: true|g" ${HOME}/config/filebeat.yml

    if [ ! -z "${SETUP_ILM_POLICY_NAME}" ]; then
        sed -i "s|^setup.ilm.policy_name:.*$|setup.ilm.policy_name: ${SETUP_ILM_POLICY_NAME}|g" ${HOME}/config/filebeat.yml
    fi

    if [ -z "${SETUP_ILM_POLICY_MAX_SIZE}" ]; then
        SETUP_ILM_POLICY_MAX_SIZE=50GB
    fi

    if [ -z "${SETUP_ILM_POLICY_MIN_AGE}" ]; then
        SETUP_ILM_POLICY_MIN_AGE=30d
    fi

    sed -i "s/\"max_size\":.*/\"max_size\": \"${SETUP_ILM_POLICY_MAX_SIZE}\",/g" ${HOME}/config/policy/filebeat.json
    sed -i "s/\"min_age\":.*/\"min_age\": \"${SETUP_ILM_POLICY_MIN_AGE}\",/g" ${HOME}/config/policy/filebeat.json
fi

if [ ! -z "${INPUT_FILE_PATTERN_LIST}" ]; then
    sed -i "/^- type: log$/,/^[ ]*enabled:.*/{s/^[ ]*enabled:.*$/  enabled: true/g}}" ${HOME}/config/filebeat.yml

    INPUT_FILE_PATTERN_LIST=${INPUT_FILE_PATTERN_LIST//,/ }
    for FILE_PATTERN in ${INPUT_FILE_PATTERN_LIST}
    do
        grep -Fq "${FILE_PATTERN}" ${HOME}/config/filebeat.yml || \
            sed -i "/^- type: log$/,/^[ ]*multiline.pattern:.*/{s|^[ ]*paths:$|&\\n    - ${FILE_PATTERN}|g}}" ${HOME}/config/filebeat.yml
    done
fi

if [ ! -z "${OUTPUT_FIELDS}" ]; then
    sed -i '/^#fields:.*$/,/^#[ ]*env:.*$/{s/#//g}' ${HOME}/config/filebeat.yml
    IFS=','
    for FIELD in ${OUTPUT_FIELDS}
    do
        grep -Fq "${FIELD}" ${HOME}/config/filebeat.yml || \
            sed -i "/^fields:.*$/,/^[ ]*env:.*$/{s|^fields:.*$|&\\n  ${FIELD}|g}}" ${HOME}/config/filebeat.yml
    done
fi

# ${HOME}/filebeat -c ${HOME}/config/filebeat.yml setup -e \
#     --path.home ${HOME} \
#     --path.data ${HOME}/data \
#     --path.logs ${HOME}/logs \
#     --path.config ${HOME}/config

${HOME}/filebeat -c ${HOME}/config/filebeat.yml -e \
    --path.home ${HOME} \
    --path.data ${HOME}/data \
    --path.logs ${HOME}/logs \
    --path.config ${HOME}/config
