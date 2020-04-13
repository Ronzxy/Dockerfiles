#!/bin/bash

WORK_HOME=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

CONTAINER_IMAGE=tomcat:8.5-jdk8
CONTAINER_NAME=tomcatAppAgents
CONTAINER_DATA=/storage/data/${CONTAINER_NAME}
CONTAINER_PORT=8083
CONTAINER_CPU_SHARES=512
CONTAINER_MEMORY=2560m

func_create() {
    docker ps -a | grep -e ".*\s${CONTAINER_NAME}\s.*" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Container ${CONTAINER_NAME} alraedy created"
    else
        docker run --name ${CONTAINER_NAME} \
        -p ${CONTAINER_PORT}:8080 \
        -v ${CONTAINER_DATA}:/var/data/tomcat \
        -e CATALINA_OUT="catalina.%Y-%m-%d-%H.out" \
        --cpu-shares=${CONTAINER_CPU_SHARES} \
        --memory=${CONTAINER_MEMORY} --memory-swap=-1 \
        --oom-kill-disable=true \
        --restart=always \
        -d ${CONTAINER_IMAGE}
    fi
}

func_start() {
    docker ps -a | grep -e ".*\s${CONTAINER_NAME}\s.*" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker ps | grep -e ".*\s${CONTAINER_NAME}\s.*" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            docker start ${CONTAINER_NAME}
        fi
    else
        echo "Not found container ${CONTAINER_NAME}, please create it first"
    fi
}

func_stop() {
    docker ps | grep -e ".*\s${CONTAINER_NAME}\s.*" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker stop ${CONTAINER_NAME}
    else
        echo "Container ${CONTAINER_NAME} not running"
    fi
}

func_status() {
    docker ps -a | grep -e ".*\s${CONTAINER_NAME}\s.*" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker ps | grep -e ".*\s${CONTAINER_NAME}\s.*" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "Container ${CONTAINER_NAME} not running"
        else
            echo "Container ${CONTAINER_NAME} is running"
        fi
    else
        echo "Not found container ${CONTAINER_NAME}, please create it first"
    fi
}

func_delete() {
    docker ps -a | grep -e ".*\s${CONTAINER_NAME}\s.*" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker ps | grep -e ".*\s${CONTAINER_NAME}\s.*" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            docker stop ${CONTAINER_NAME} > /dev/null 2>&1
        fi

        docker rm -v ${CONTAINER_NAME}
    else
        echo "Not found container ${CONTAINER_NAME}, please create it first"
    fi
}

case "$1" in
    create)
        func_create

        exit 0
    ;;
    start)
        func_start

        exit 0
    ;;
    stop)
        func_stop

        exit 0
    ;;
    status)
        func_status

        exit 0
    ;;
    delete)
        func_delete

        exit 0
    ;;
    *)
        echo $"Usage: {create | start | stop | status | delete}"
        exit 1
    ;;
esac