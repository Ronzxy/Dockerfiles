#!/bin/sh

if [ ! -d "${CATALINA_HOME}" ]; then
    mkdir -p ${CATALINA_HOME}
fi

if [ ! -d "${CATALINA_HOME}/logs" ]; then
    mkdir -p ${CATALINA_HOME}/logs
fi

if [ ! -d "${CATALINA_HOME}/temp" ]; then
    mkdir -p ${CATALINA_HOME}/temp
fi

if [ ! -d "${CATALINA_HOME}/work" ]; then
    mkdir -p ${CATALINA_HOME}/work
fi

sh ${CATALINA_HOME}/bin/catalina.sh run 2>&1 | cronolog "${CATALINA_HOME}/logs/${CATALINA_OUT}"
