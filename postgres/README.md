# PostgreSQL

Build and create postgres docker image from the alpine edge.

### Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/postgres
chmod 755 builder
./builder image
```

### Usage

```sh

# mkdir -p /home/storage/run/docker/postgres/data

docker run --name postgres \
    -h postgres.ronzxy.com \
    -p 5432:5432 \
    -v postgres-data:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=1024 --memory=2G --memory-swap=4G \
    --restart=on-failure \
    -it -d docker.ronzxy.com/postgres:12.3

```

### Create DB

```sh

CONTAINER_NAME=postgres
docker exec ${CONTAINER_NAME} psql -U postgres -c "
CREATE USER ronzxy WITH
    LOGIN
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT
    NOREPLICATION
    CONNECTION LIMIT -1
    PASSWORD 'Abc123';
"
docker exec ${CONTAINER_NAME} psql -U postgres -c "
CREATE DATABASE ronzxydb
    WITH
    OWNER = ronzxy
    ENCODING = 'UTF8'
    LC_COLLATE = 'zh_CN.UTF-8'
    LC_CTYPE = 'zh_CN.UTF-8'
    CONNECTION LIMIT = -1;
"


```
