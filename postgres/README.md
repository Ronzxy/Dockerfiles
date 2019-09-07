Nginx
=====

Build postgres docker image from alpine edge.

# Usage:
```shell
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfile/postgres
chmod 755 builder
./builder image
```

# 创建容器
```shell

mkdir -p /home/storage/run/docker/postgres/data

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name postgres \
    -h postgres.erayun.cn \
    -p 5432:5432 \
    -v /home/storage/run/docker/postgres/data:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=1024 --memory=16G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    --privileged \
    -it -d skygangsta/postgres:11.5-alpine

```
