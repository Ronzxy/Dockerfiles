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

mkdir -p /home/storage/run/docker/postgres/data

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name postgres \
    -h postgres.erayun.cn \
    -p 5432:5432 \
    -v postgres-data:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=1024 --memory=16G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/postgres:12.1

```
