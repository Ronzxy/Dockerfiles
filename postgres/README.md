Nginx
=====

Auto build nginx and create nginx docker image in debian.

# Usage:
```shell
git clone https://github.com/skygangsta/Dockerfile.git
cd Dockerfile/nginx
chmod 755 builder
./builder
```

# 创建容器
```shell
docker run --name postgres \
    -h postgres.erayun.cn \
    -p 5432:5432 \
    -v /home/storage/run/docker/postgres/data:/var/lib/postgres \
    --cpu-shares=1024 --memory=30G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --privileged \
    -it -d skygangsta/postgres:11.5-alpine


mkdir -p /home/storage/run/docker/postgres/data
podman run --name postgres \
    -h postgres \
    -p 5432:5432 \
    -v /home/storage/run/docker/postgres/data:/var/lib/postgres \
    --cpu-shares=1024 --memory=16G --memory-swap=0 \
    --oom-kill-disable \
    --privileged \
    -it -d skygangsta/postgres:11.5-alpine
```

# 创建 PostgreSQL 集群

```shell

docker run --name postgres_master \
    -h postgres-master \
    -p 54321:5432 \
    -v /home/storage/run/docker/postgres/meta/master:/var/lib/postgres \
    -e POSTGRES_PASSWORD=123456 \
    -e SYNC_MODE=SYNC \
    -e NETWORK="172.17.0.0/24" \
    --cpu-shares=512 --memory=2G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/postgres:11.5-alpine

sleep 5

docker run --name postgres_backup1 \
    -h postgres-backup1 \
    -p 54322:5432 \
    -v /home/storage/run/docker/postgres/meta/backup1:/var/lib/postgres \
    -e PGTYPE="BACKUP" \
    -e PGMASTER_HOST="172.17.0.1" \
    -e PGMASTER_PORT=54321 \
    -e SYNC_MODE=SYNC \
    -e SYNC_NAME="pg_backup1" \
    --cpu-shares=512 --memory=1G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/postgres:11.5-alpine

docker run --name postgres_backup2 \
    -h postgres-backup2 \
    -p 54323:5432 \
    -v /home/storage/run/docker/postgres/meta/backup2:/var/lib/postgres \
    -e PGTYPE="BACKUP" \
    -e PGMASTER_HOST="172.17.0.1" \
    -e PGMASTER_PORT=54321 \
    -e SYNC_MODE=SYNC \
    -e SYNC_NAME="pg_backup2" \
    --cpu-shares=512 --memory=1G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/postgres:11.5-alpine

```







