#!/bin/sh
#
#  Author: Zhang Chaoren<zhangchaoren@mx.aketi.cn>
# Version: v19.08.23.1
#
# PostgreSQL initial and start up, support docker


PGHOME=/usr/postgres

PGUSER=postgres
PGGROUP=postgres

func_check_ld_conf() {
    ldconfig $PGHOME/lib
}

func_init() {
    echo "Initial PostgreSQL..."

    if [ "${#POSTGRES_PASSWORD}" -ge 100 ]; then
        cat >&2 <<-'EOWARN'
            WARNING: The supplied POSTGRES_PASSWORD is 100+ characters.
                This will not work if used via PGPASSWORD with "psql".
                https://www.postgresql.org/message-id/flat/E1Rqxp2-0004Qt-PL%40wrigleys.postgresql.org (BUG #6412)
		EOWARN
    fi

    if [ -z ${POSTGRES_PASSWORD} ]; then
        POSTGRES_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`
    fi
    
    for i in $PGHOME/bin/*; do
        if [ -x $i ]; then
            ln -sf $i /usr/bin/`basename $i`
        fi
    done
    
    for i in /usr/glibc-compat/bin/*; do
        if [ -x $i ]; then
            ln -sf $i /usr/bin/`basename $i`
        fi
    done
    
    if [ ! -d ${PGDATA} ]; then
        mkdir -p ${PGDATA}
    fi

    chown -R ${PGUSER}:${PGGROUP} ${PGDATA} > /dev/null 2>&1
    chmod 0700 ${PGDATA} > /dev/null 2>&1

    su - ${PGUSER} -c "echo ${POSTGRES_PASSWORD} > \${HOME}/POSTGRES_PASSWORD"
    su - ${PGUSER} -c "$PGHOME/bin/initdb -D ${PGDATA} -E UTF-8 -k --locale=${LANG} -T simple --user=${PGUSER} --pwfile=\${HOME}/POSTGRES_PASSWORD"
    su - ${PGUSER} -c "cp ${PGDATA}/postgresql.conf ${PGDATA}/postgresql.conf.default"
    su - ${PGUSER} -c "mv \${HOME}/POSTGRES_PASSWORD ${PGDATA}"
    
    # 监听连接数
    sed -i -E "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#port = 5432/port = 5432/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/max_connections = 100/max_connections = 1024/g" ${PGDATA}/postgresql.conf
    
    sed -i -E "s/shared_buffers = 128MB/shared_buffers = 512MB/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#huge_pages = try/huge_pages = try/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#max_prepared_transactions = 0/max_prepared_transactions = 256/g" ${PGDATA}/postgresql.conf

    # wal
    sed -i -E "s/#max_wal_senders = 10/max_wal_senders = 10/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#wal_level = replica/wal_level = hot_standby/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#wal_buffers = -1/wal_buffers = 64MB/g" ${PGDATA}/postgresql.conf

    # 开启数据库性能视图
    sed -i -E "s/#track_counts = on/track_counts = on/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#track_functions = none/track_functions = all/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#track_activities = on/track_activities = on/g" ${PGDATA}/postgresql.conf
    # 测试 timing 代价小于 50 开启收集 I/O 信息
    if [ -x $PGHOME/bin/pg_test_timing ]; then
		TIMING=$($PGHOME/bin/pg_test_timing | grep 'Per loop time including overhead' | awk -F ': ' '{print $2}')
		TIMING_UNIT=$(echo $TIMING | awk -F ' ' '{print $2}')
		TIMING=$(echo $TIMING | awk -F ' ' '{print $1}')
		TIMING_REST=$(echo "$TIMING  50" | awk '{if ($1 < $2) print 1;else print 0}')
		if [ $TIMING_REST -gt 0 -a "$TIMING_UNIT" = "ns" ]; then
			sed -i -E "s/#track_io_timing = off/track_io_timing = on/g" ${PGDATA}/postgresql.conf
		else
			echo "Notice: pg_test_timing Per loop time including overhead: $TIMING $TIMING_UNIT"
			echo "        The option track_io_timing will not be enabled."
		fi
    fi

    # 自动清理
    sed -i -E "s/#autovacuum = on/autovacuum = on/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#autovacuum_max_workers = 3/autovacuum_max_workers = 3/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#autovacuum_vacuum_cost_delay = 20ms/autovacuum_vacuum_cost_delay = 4ms/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#autovacuum_vacuum_threshold = 50/autovacuum_vacuum_threshold = 50/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#autovacuum_analyze_threshold = 50/autovacuum_analyze_threshold = 50/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#autovacuum_vacuum_scale_factor = 0.2/autovacuum_vacuum_scale_factor = 0.2/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#autovacuum_analyze_scale_factor = 0.1/autovacuum_analyze_scale_factor = 0.1/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#autovacuum_freeze_max_age = 200000000/autovacuum_freeze_max_age = 200000000/g" ${PGDATA}/postgresql.conf

    # 预写式日志
    sed -i -E "s/#checkpoint_completion_target = 0.5/checkpoint_completion_target = 0.7/g" ${PGDATA}/postgresql.conf

    # 开启日志收集
    sed -i -E "s/#logging_collector = off/logging_collector = on/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#log_destination = 'stderr'/log_destination = 'csvlog'/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#log_directory = 'log'/log_directory = 'pg_log'/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#log_rotation_age = 1d/log_rotation_age = 1d/g" ${PGDATA}/postgresql.conf
    sed -i -E "s/#log_rotation_size = 10MB/log_rotation_size = 128MB/g" ${PGDATA}/postgresql.conf

    # 闲置事务会话超时 60 秒(60000 毫秒)
    sed -i -E "s/#idle_in_transaction_session_timeout = 0/idle_in_transaction_session_timeout = 60000/g" ${PGDATA}/postgresql.conf

    if [ "$SYNC_MODE" = "SYNC" ]; then
        # 开启流复制
        sed -i -E "s/#synchronous_commit = on/synchronous_commit = remote_write/g" ${PGDATA}/postgresql.conf
        sed -i -E "s/#synchronous_standby_names = ''/synchronous_standby_names = '*'/g" ${PGDATA}/postgresql.conf
        # 授权指定网络复制权限
        if [ "${NETWORK}" != "127.0.0.1/32" ]; then
            echo "# Allow replication connections from specific network, by a user with the" >> ${PGDATA}/pg_hba.conf
            echo "# replication privilege."                                                  >> ${PGDATA}/pg_hba.conf
            echo "host    replication     all             ${NETWORK}            trust"       >> ${PGDATA}/pg_hba.conf
        fi
    else
        if [ "${NETWORK}" != "127.0.0.1/32" ]; then
            echo "# Allow the specified host unrestricted access to connect"               >> ${PGDATA}/pg_hba.conf
            echo "host    all             all             ${NETWORK}                trust" >> ${PGDATA}/pg_hba.conf
        fi
    fi

    echo "# Allow all host authorized access to connect"                        >> ${PGDATA}/pg_hba.conf
    echo "host    all             all             all                     md5"  >> ${PGDATA}/pg_hba.conf

    echo "# Must keep citus first" >> ${PGDATA}/postgresql.conf
    echo "shared_preload_libraries = 'citus'" >> ${PGDATA}/postgresql.conf
}

func_backup() {
    echo "Initial base backup from ${PGMASTER_HOST}:${PGMASTER_PORT}..."

    if [ ! -d ${PGDATA} ]; then
        mkdir -p ${PGDATA}
    fi

    chown -R ${PGUSER}:${PGGROUP} ${PGDATA} > /dev/null 2>&1
    chmod 0700 ${PGDATA} > /dev/null 2>&1

    su - ${PGUSER} -c "$PGHOME/bin/pg_basebackup -h ${PGMASTER_HOST} -p ${PGMASTER_PORT} -U postgres -F p -P -R -D ${PGDATA} -l base_backup_$(date +%Y_%m_%d_%H%M%S)"

    sed -i -E "s/#hot_standby = on/hot_standby = on/g" ${PGDATA}/postgresql.conf

    if [ "$SYNC_MODE" = "SYNC" ]; then
        # 同步复制需要应用名称
        sed -i -E "s/user=postgres/application_name=${SYNC_NAME} user=postgres/g" ${PGDATA}/recovery.conf
    fi
}

func_start() {
    func_check_ld_conf

    # # 调整预读 -- 要配置数据所在磁盘参数
    # blockdev --setra 4096 /dev/vdb1
    # # 调整 I/O 调度器-- 要配置数据所在磁盘参数
    # echo deadline > /sys/block/vdb/queue/scheduler
    # # 调整虚拟内存参数
    # sysctl -w vm.swappiness=0
    # # 调整内存分配 -- 要根据物理内存和 Swap 大小进行合理配置
    # # 调整公式 swap + N% * mem
    # # N% 由 vm.overcommit_ratio 控制
    # sysctl -w vm.overcommit_memory=2
    # sysctl -w vm.overcommit_ratio=99
    # # 写缓存优化
    # sysctl -w vm.dirty_background_ratio=3
    # sysctl -w vm.dirty_ratio=6

    if [ ! -f "${PGDATA}/PG_VERSION" ]; then
        echo "PostgreSQL not initialization..."

        if [ "${PGTYPE}" == "BACKUP" ]; then
            func_backup
        else
            func_init
        fi
    fi
    # 启动 PostgreSQL
    if [ -f .dockerenv ]; then
        su - ${PGUSER} -c "$PGHOME/bin/postgres -D ${PGDATA}"
    else
        su - ${PGUSER} -c "$PGHOME/bin/pg_ctl -D ${PGDATA} -w start"
    fi

    # # 执行配置
    # if [ "${PGTYPE}" == "MASTER" ]; then
    #     PSQL=($PGHOME/bin/psql -v ON_ERROR_STOP=1)
    #     "${PSQL[@]}" --username postgres <<-EOSQL
    #         --
    #         -- What's done in this file shouldn't be replicated
    #         --
	# 	EOSQL
    # fi
}

func_stop() {
    func_check_ld_conf

    if [ -f "${PGDATA}/postmaster.pid" ]; then
        if [ "$1" = "" ]; then
            su - ${PGUSER} -c "$PGHOME/bin/pg_ctl -D ${PGDATA} stop -m fast"
        else
            su - ${PGUSER} -c "$PGHOME/bin/pg_ctl -D ${PGDATA} stop -m $1"
        fi
        # kill -TERM $(head -1 ${PGDATA}/postmaster.pid)
        # su - postgres -c "$PGHOME/bin/pg_ctl -D ${PGDATA} stop -m smart"
        # su - postgres -c "$PGHOME/bin/pg_ctl -D ${PGDATA} stop -m fast"
        # su - postgres -c "$PGHOME/bin/pg_ctl -D ${PGDATA} stop -m immediate"
    fi
}

func_reload() {
    func_check_ld_conf

    if [ -f "${PGDATA}/postmaster.pid" ]; then
        su - ${PGUSER} -c "$PGHOME/bin/pg_ctl -D ${PGDATA} reload"
    fi
}

func_help() {
    echo "
Usage:
    start   Start postgres service
    reload  Reload postgres
    stop    Fast stop postgres service. And smart,immediate available
    restart Restart postgres service.
    help    Print help infomation
"
}

# 检查是否为 root 用户
if [ "$(id -u)" != "0" ]; then
    echo "Error: Please use the root user to execute this shell."
    exit 1
fi

set -e

case "$1" in
    start)
        func_start
        
        exit 0
    ;;
    reload)
        func_reload

        exit 0
    ;;
    stop)
        func_stop $2

        exit 0
    ;;
    restart)
        func_stop
        sleep 1
        func_start

        exit 0
    ;;
    help)
        func_help
        
        exit 0
    ;;
    *)
        func_help

        exit 1
    ;;
esac
