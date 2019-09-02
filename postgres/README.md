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
