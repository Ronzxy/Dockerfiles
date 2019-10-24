# Create PostgreSQL cluster

Create PostgreSQL cluster with citus

## Create MASTER and WORKER node

```sh

CONTAINER_ENGINE=docker
CONTAINER_IMAGE=skygangsta/postgres:12.0-alpine
${CONTAINER_ENGINE} run --name postgres-master \
    -h master.postgres.erayun.cn \
    -p 5432:5432 \
    -v /home/storage/run/docker/postgres/meta/master:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e POSTGRES_PASSWORD=Abc@123 \
    -e SYNC_MODE=SYNC \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=2G --memory-swap=-1 \
    --restart=always \
    --oom-kill-disable \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

sleep 5

${CONTAINER_ENGINE} run --name postgres-backup1 \
    -h backup1.postgres.erayun.cn \
    -p 5433:5432 \
    -v /home/storage/run/docker/postgres/meta/backup1:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e PGTYPE="BACKUP" \
    -e PGMASTER_HOST="172.17.0.1" \
    -e PGMASTER_PORT=5432 \
    -e SYNC_MODE=SYNC \
    -e SYNC_NAME="pg_backup1" \
    --cpu-shares=256 --memory=256M --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

${CONTAINER_ENGINE} run --name postgres-backup2 \
    -h backup2.postgres.erayun.cn \
    -p 5434:5432 \
    -v /home/storage/run/docker/postgres/meta/backup2:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e PGTYPE="BACKUP" \
    -e PGMASTER_HOST="172.17.0.1" \
    -e PGMASTER_PORT=5432 \
    -e SYNC_MODE=SYNC \
    -e SYNC_NAME="pg_backup2" \
    --cpu-shares=256 --memory=256M --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

## Create WORKER node

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name postgres-worker01 \
    -h worker01.postgres.erayun.cn \
    -p 54321:5432 \
    -v /home/storage/run/docker/postgres/meta/worker01:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

${CONTAINER_ENGINE} run --name postgres-worker02 \
    -h worker02.postgres.erayun.cn \
    -p 54322:5432 \
    -v /home/storage/run/docker/postgres/meta/worker02:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

${CONTAINER_ENGINE} run --name postgres-worker03 \
    -h worker03.postgres.erayun.cn \
    -p 54323:5432 \
    -v /home/storage/run/docker/postgres/meta/worker03:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

${CONTAINER_ENGINE} run --name postgres-worker04 \
    -h worker04.postgres.erayun.cn \
    -p 54324:5432 \
    -v /home/storage/run/docker/postgres/meta/worker04:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

${CONTAINER_ENGINE} run --name postgres-worker05 \
    -h worker05.postgres.erayun.cn \
    -p 54325:5432 \
    -v /home/storage/run/docker/postgres/meta/worker05:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

```

## Initialize the cluster

```sh

CONTAINER_ENGINE=docker
POSTGRES_CLUSTER=(postgres-master postgres-worker01 postgres-worker02 postgres-worker03 postgres-worker04 postgres-worker05)
for NODE in ${POSTGRES_CLUSTER[@]}; do

    ${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -c "
CREATE USER citusdb WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'Abc@123';
"

    ${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -c "
CREATE DATABASE citusdb
    WITH 
    OWNER = citusdb
    ENCODING = 'UTF8'
    LC_COLLATE = 'zh_CN.UTF-8'
    LC_CTYPE = 'zh_CN.UTF-8'
    CONNECTION LIMIT = -1;
"

    ${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "CREATE EXTENSION citus;"
    ${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "CREATE EXTENSION hll;"

done


NODE=postgres-master

${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54321);"
${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54322);"
${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54323);"
${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54324);"
${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54325);"


${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SELECT * FROM master_get_active_worker_nodes();"

# 设置表分片数
${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SET citus.shard_count = 64;"
# 设置表分片的副本数量
${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SET citus.shard_replication_factor = 2;"
# 设置Citus在使用postgresql-hll扩展计算count（distinct）时所需的错误率
${CONTAINER_ENGINE} exec -it ${NODE} psql -U postgres -d citusdb -c "SET citus.count_distinct_error_rate = 0.005;"



# postgres-master postgres-worker01 postgres-worker02 postgres-worker03 postgres-worker04 postgres-worker05 postgres-backup1 postgres-backup2

```
