#!/bin/sh

if [ ! -d ${REDIS_DATA_PATH} ]; then
    mkdir -p ${REDIS_DATA_PATH}
fi

if [ ! -f ${REDIS_DATA_PATH}/redis.conf ]; then
    cp /usr/redis/conf/redis.conf ${REDIS_DATA_PATH} || exit 1
fi

if [ ! -f ${REDIS_DATA_PATH}/sentinel.conf ]; then
    cp /usr/redis/conf/sentinel.conf ${REDIS_DATA_PATH} || exit 1
fi

for i in /usr/redis/bin/*; do
    if [ -x $i ]; then
        ln -sf $i /usr/bin/`basename $i`
    fi
done

if [ ${APPEND_ONLY}x == yesx ]; then
    APPEND_ONLY="yes"
else
    APPEND_ONLY="no"
fi

if [ -z ${REDIS_PORT} ]; then
    REDIS_PORT=6379
fi

if [ ${CLUSTER_ENABLE}x == yesx ]; then
    CLUSTER_ENABLE="yes"
    sed -i "s|^protected-mode.*$|protected-mode no|g" ${REDIS_DATA_PATH}/redis.conf
    sed -i "s|^#\ cluster-enabled.*$|cluster-enabled ${CLUSTER_ENABLE}|g" ${REDIS_DATA_PATH}/redis.conf
    sed -i "s|^#\ cluster-config-file.*$|cluster-config-file nodes-${REDIS_PORT}.conf|g" ${REDIS_DATA_PATH}/redis.conf
    sed -i "s|^#\ cluster-node-timeout.*$|cluster-node-timeout 5000|g" ${REDIS_DATA_PATH}/redis.conf    
else
    CLUSTER_ENABLE="no"
    sed -i "s|^#\ cluster-enabled.*$|cluster-enabled ${CLUSTER_ENABLE}|g" ${REDIS_DATA_PATH}/redis.conf
fi

sed -i "s|^port.*|port ${REDIS_PORT}|g" ${REDIS_DATA_PATH}/redis.conf
sed -i "s|^bind.*$|bind 0.0.0.0|g" ${REDIS_DATA_PATH}/redis.conf
sed -i "s|^dir.*$|dir ${REDIS_DATA_PATH}|g" ${REDIS_DATA_PATH}/redis.conf

/usr/bin/redis-server ${REDIS_DATA_PATH}/redis.conf \
    --daemonize no --bind 0.0.0.0 --port ${REDIS_PORT} --dir ${REDIS_DATA_PATH} \
    --appendonly ${APPEND_ONLY} --cluster-enabled ${CLUSTER_ENABLE}
