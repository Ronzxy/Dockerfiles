# MariaDb

Build and create mariadb docker image from the alpine image.

### Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/mariadb
chmod 755 builder
./builder image
```

### Usage

```sh

docker run --name mariadb \
    -h mariadb.ronzxy.com \
    -p 3306:3306 \
    -v mariadb-conf:/etc/my.cnf.d:rw,z\
    -v mariadb-data:/var/lib/mysql:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e MYSQL_ROOT_PASSWORD="Abc123" \
    --cpu-shares=1024 --memory=1G --memory-swap=0 \
    --restart=on-failure \
    --oom-kill-disable \
    -it -d docker.ronzxy.com/mariadb:10.4

```

### Create database

```sh

MYSQL_DATABASE="wsym"
MYSQL_CHARSET="utf8"
MYSQL_COLLATION="utf8_general_ci"
MYSQL_USER="wsym"
MYSQL_PASSWORD="Abc123"

if [ "$MYSQL_PASSWORD" = "" ]; then
    MYSQL_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`
fi

echo "[i] with character set: 'utf8' and collation: 'utf8_general_ci'"
echo "[i] Creating user: '$MYSQL_USER' with password '$MYSQL_PASSWORD'"
echo "
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET ${MYSQL_CHARSET} COLLATE ${MYSQL_COLLATION};
GRANT ALL ON ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
" | mysql -h 127.0.0.1 -u root -p

```

### SQL

```sql

show master logs;
-- 清除 mysql-bin.000001 日志
PURGE MASTER LOGS TO 'mysql-bin.000001';
-- 清除 2008-06-22 13:00:00 前的 binlog
PURGE MASTER LOGS BEFORE '2008-06-22 13:00:00';
-- 手动清除大于10天的 binlog
PURGE MASTER LOGS BEFORE DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY);
-- 设置 binlog 过期时间
set global expire_logs_days = 10;

reset master;

```

### Configuration

```sh

cat > master.cnf <<EOF
[galera]
# Replication Master Server (default)
# binary logging is required for replication
log-bin           = mysql-bin
log_bin_compress  = on
# binary logging format - mixed recommended
binlog_format     = mixed
expire_logs_days  = 15
server_id         = 0
EOF

cat > slave.cnf <<EOF
[galera]
# Replication Master Server (default)
# binary logging is required for replication
log-bin           = mysql-bin
log_bin_compress  = on
log_slave_updates = 1
# binary logging format - mixed recommended
binlog_format     = mixed
expire_logs_days  = 15
server_id         = 1
EOF

cat > conn.cnf <<EOF
[galera]
character_set_server=utf8
init_connect='SET NAMES utf8'
autocommit = 1
max_connections = 1000
max_connect_errors = 1000
transaction_isolation = READ-COMMITTED
EOF

cat > innodb.cnf <<EOF
[galera]
innodb_large_prefix = 1
innodb_thread_concurrency = 8
innodb_print_all_deadlocks = 1
innodb_sort_buffer_size = 16M
innodb_lock_wait_timeout = 500
EOF

cat > slow.cnf <<EOF
[galera]
slow_query_log = on
long_query_time = 3
slow_query_log_file = mariadb-slow.log
EOF

```
