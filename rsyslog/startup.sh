#!/bin/sh
#
#  Author: Zhang Chaoren<zhangchaoren@mx.aketi.cn>
# Version: v19.08.23.1
#
# Rsyslog starts and rotates the log file in the docker alpine container

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

DISABLE_IMKLOG=`echo ${DISABLE_IMKLOG} | tr 'a-z' 'A-Z'`
DISABLE_IMMARK=`echo ${DISABLE_IMMARK} | tr 'a-z' 'A-Z'`
DISABLE_DEBUG=`echo ${DISABLE_DEBUG} | tr 'a-z' 'A-Z'`

if [ ${DISABLE_DEBUG:-true} = "FALSE" ]; then
    set -ex
fi

func_start_rsyslog() {
    if [ "${DISABLE_IMKLOG:-false}" = "TRUE" ]; then
        sed -i 's/^module(load=\"imklog\")$/# &/g' /etc/rsyslog.conf
    fi

    if [ "${DISABLE_IMMARK:-false}" = "TRUE" ]; then
        sed -i 's/^module(load=\"immark\")$/# &/g' /etc/rsyslog.conf
    fi

    if [ ! -d /etc/-rsyslog.d ]; then
        mkdir -p /etc/rsyslog.d
    fi

    if [ ! -f /etc/rsyslog.d/00-template.conf ]; then
        cp /etc/rsyslog.d.sample/00-template.conf /etc/rsyslog.d
    fi

    if [ ! -f /etc/rsyslog.d/10-ompgsql.conf.sample ]; then
        cp /etc/rsyslog.d.sample/10-ompgsql.conf /etc/rsyslog.d/10-ompgsql.conf.sample
    fi

    if [ ! -f /etc/rsyslog.d/99-listen.conf ]; then
        cp /etc/rsyslog.d.sample/99-listen.conf /etc/rsyslog.d
    fi

    if [ ! -f /etc/rsyslog.d/pgsql-createDB.sql ]; then
        cp /etc/rsyslog.d.sample/pgsql-createDB.sql /etc/rsyslog.d/pgsql-createDB.sql
    fi

    if [ ! -f /var/log/backup.sh ]; then
        cp backup.sh /var/log/
    fi

    if [ -f /var/run/rsyslogd.pid ]; then
        rm -rf /var/run/rsyslogd.pid
    fi

    if [ "${DISABLE_DEBUG:-false}" = "TRUE" ]; then
        /usr/sbin/rsyslogd -n -i /var/run/rsyslogd.pid -f /etc/rsyslog.conf
    else
        /usr/sbin/rsyslogd -dn -i /var/run/rsyslogd.pid -f /etc/rsyslog.conf
    fi
}

func_check_file() {
    if [ ! -f /var/log/auth.log ]; then
        touch /var/log/auth.log
    fi

    if [ ! -f /var/log/boot.log ]; then
        touch /var/log/boot.log
    fi

    if [ ! -f /var/log/cron.log ]; then
        touch /var/log/cron.log
    fi

    if [ ! -f /var/log/kern.log ]; then
        touch /var/log/kern.log
    fi

    if [ ! -f /var/log/mail.log ]; then
        touch /var/log/mail.log
    fi

    if [ ! -f /var/log/messages ]; then
        touch /var/log/messages
    fi
}

func_rotate_log() {
    sed -i "s|/etc/init.d/rsyslog --ifstarted reload >/dev/null|/bin/kill -HUP \`cat /var/run/rsyslogd.pid 2>/dev/null\` 2>/dev/null \|\| true|g" \
        /etc/logrotate.d/rsyslog

    sed -i "s|^/var/log/messages.*$|# &|g" /etc/logrotate.conf

    func_check_file

    /usr/sbin/logrotate -f /etc/logrotate.conf

    # /bin/kill -HUP `cat /var/run/rsyslogd.pid 2>/dev/null`
}

func_help() {
    echo "
Usage:
    start   Start rsyslog service
    rotate  Rotate rsyslog log use logrotate
    help    Print help infomation
"
}

case "$1" in
    start)
        func_start_rsyslog
        exit 0
    ;;
    rotate)
        func_rotate_log
        exit 0
    ;;
    *)
        func_help

        exit 1
    ;;
esac
