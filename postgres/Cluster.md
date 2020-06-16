# Create PostgreSQL cluster

Create PostgreSQL cluster with citus

## Create MASTER and WORKER node

```sh

CONTAINER_IMAGE=docker.ronzxy.com/postgres:12.3
docker run --name postgres-master \
    -h master.postgres.erayun.cn \
    -p 5432:5432 \
    -v postgres-data-master:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e POSTGRES_PASSWORD=Abc@123 \
    -e SYNC_MODE=SYNC \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=2G --memory-swap=-1 \
    --restart=on-failure \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

sleep 15

docker run --name postgres-backup1 \
    -h backup1.postgres.erayun.cn \
    -p 5433:5432 \
    -v postgres-data-backup1:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e PGTYPE="BACKUP" \
    -e PGMASTER_HOST="172.17.0.1" \
    -e PGMASTER_PORT=5432 \
    -e SYNC_MODE=SYNC \
    -e SYNC_NAME="pg_backup1" \
    --cpu-shares=256 --memory=256M --memory-swap=0 \
    --restart=on-failure \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

docker run --name postgres-backup2 \
    -h backup2.postgres.erayun.cn \
    -p 5434:5432 \
    -v postgres-data-backup2:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e PGTYPE="BACKUP" \
    -e PGMASTER_HOST="172.17.0.1" \
    -e PGMASTER_PORT=5432 \
    -e SYNC_MODE=SYNC \
    -e SYNC_NAME="pg_backup2" \
    --cpu-shares=256 --memory=256M --memory-swap=0 \
    --restart=on-failure \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

## Create WORKER node

CONTAINER_ENGINE=docker
docker run --name postgres-worker01 \
    -h worker01.postgres.erayun.cn \
    -p 54321:5432 \
    -v postgres-data-worker01:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=on-failure \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

docker run --name postgres-worker02 \
    -h worker02.postgres.erayun.cn \
    -p 54322:5432 \
    -v postgres-data-worker02:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=on-failure \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

docker run --name postgres-worker03 \
    -h worker03.postgres.erayun.cn \
    -p 54323:5432 \
    -v postgres-data-worker03:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=on-failure \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

docker run --name postgres-worker04 \
    -h worker04.postgres.erayun.cn \
    -p 54324:5432 \
    -v postgres-data-worker04:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=on-failure \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

docker run --name postgres-worker05 \
    -h worker05.postgres.erayun.cn \
    -p 54325:5432 \
    -v postgres-data-worker05:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=512M --memory-swap=0 \
    --restart=on-failure \
    --log-opt max-size=100m \
    --log-opt max-file=3 \
    -it -d ${CONTAINER_IMAGE}

```

## Initialize the cluster

```sh

CONTAINER_ENGINE=docker
POSTGRES_CLUSTER=(postgres-master postgres-worker01 postgres-worker02 postgres-worker03 postgres-worker04 postgres-worker05)
for NODE in ${POSTGRES_CLUSTER[@]}; do

    docker exec ${NODE} psql -U postgres -c "
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

    docker exec ${NODE} psql -U postgres -c "
CREATE DATABASE citusdb
    WITH 
    OWNER = citusdb
    ENCODING = 'UTF8'
    LC_COLLATE = 'zh_CN.UTF-8'
    LC_CTYPE = 'zh_CN.UTF-8'
    CONNECTION LIMIT = -1;
"

    docker exec ${NODE} psql -U postgres -d citusdb -c "CREATE EXTENSION citus;"
    docker exec ${NODE} psql -U postgres -d citusdb -c "CREATE EXTENSION hll;"

done


NODE=postgres-master
if [ "${NODE}" = "postgres-master" ]; then
    docker exec ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54321);"
    docker exec ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54322);"
    docker exec ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54323);"
    docker exec ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54324);"
    docker exec ${NODE} psql -U postgres -d citusdb -c "SELECT * from master_add_node('172.17.0.1', 54325);"


    docker exec ${NODE} psql -U postgres -d citusdb -c "SELECT * FROM master_get_active_worker_nodes();"

    # 设置表分片数
    docker exec ${NODE} psql -U postgres -d citusdb -c "SET citus.shard_count = 64;"
    # 设置表分片的副本数量
    docker exec ${NODE} psql -U postgres -d citusdb -c "SET citus.shard_replication_factor = 2;"
    # 设置Citus在使用postgresql-hll扩展计算count（distinct）时所需的错误率
    docker exec ${NODE} psql -U postgres -d citusdb -c "SET citus.count_distinct_error_rate = 0.005;"
fi


# postgres-master postgres-worker01 postgres-worker02 postgres-worker03 postgres-worker04 postgres-worker05 postgres-backup1 postgres-backup2

```
