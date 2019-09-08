# 创建 rsyslog-server POD

## 创建 rsyslog pod
podman pod create --name rsyslog \
-p 80:80/tcp \
-p 443:443/tcp \
-p 5140:514/tcp \
-p 5140:514/udp \
-p 3306:3306/tcp \
-p 5432:5432/tcp

## 创建 postgres 容器
mkdir -p /home/storage/run/docker/rsyslog/postgres
podman run \
    --pod rsyslog \
    --name rsyslog-postgres \
    -h rsyslog-server.container.cn \
    -v /home/storage/run/docker/rsyslog/postgres:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e POSTGRES_PASSWORD=mymsBll1mHjgZHKA \
    --cpu-shares=1024 --memory=16G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/postgres:11.5-alpine

sleep 3

podman exec -it rsyslog-postgres /usr/postgres/bin/psql -U postgres -c "

CREATE USER rsyslog WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'Abc123';
"

podman exec -it rsyslog-postgres /usr/postgres/bin/psql -U postgres -c "

CREATE DATABASE rsyslog
    WITH 
    OWNER = rsyslog
    ENCODING = 'UTF8'
    LC_COLLATE = 'zh_CN.UTF-8'
    LC_CTYPE = 'zh_CN.UTF-8'
    CONNECTION LIMIT = -1;
"

## 创建 rsyslog-server 容器
mkdir -p /home/storage/run/docker/rsyslog/{conf,data}
podman run \
    --pod rsyslog \
    --name rsyslog-server \
    -h rsyslog-server.container.cn \
    -v /home/storage/run/docker/rsyslog/conf:/etc/rsyslog.d:rw,z \
    -v /home/storage/run/docker/rsyslog/data:/var/log:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=1024 --memory=2G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --privileged \
    -it -d skygangsta/rsyslog:alpine-edge


## 创建 MySQL (Percona Server) 容器
mkdir -p /home/storage/run/docker/rsyslog/percona
chown 999:999 /home/storage/run/docker/rsyslog/percona
podman run \
--pod rsyslog \
--name rsyslog-percona \
-h rsyslog-server.container.cn \
-v /home/storage/run/docker/rsyslog/percona:/var/lib/mysql:rw,z \
-v /etc/resolv.conf:/etc/resolv.conf:ro,z \
-e MYSQL_ROOT_PASSWORD=mymsBll1mHjgZHKA \
--cpu-shares=1024 --memory=4G --memory-swap=0 \
--restart=always \
--oom-kill-disable \
-it -d percona:5.7.26

CREATE DATABASE loganalyzer CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin';
GRANT ALL PRIVILEGES ON loganalyzer.* TO loganalyzer@'%' IDENTIFIED BY 'Abc123' WITH GRANT OPTION;

## 创建 php 容器并安装 loganalyzer
mkdir -p /home/storage/run/docker/rsyslog/{nginx,html,cert,php,logs}
podman run \
    --pod rsyslog \
    --name rsyslog-php \
    -h rsyslog-server.container.cn \
    -v /home/storage/run/docker/rsyslog/nginx:/usr/nginx/conf:rw,z \
    -v /home/storage/run/docker/rsyslog/html:/usr/nginx/html:rw,z \
    -v /home/storage/run/docker/rsyslog/cert:/usr/nginx/cert:rw,z \
    -v /home/storage/run/docker/rsyslog/logs:/var/log/nginx:rw,z \
    -v /home/storage/run/docker/rsyslog/php:/etc/php:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=512 --memory=2G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/php:7.3.9-alpine




