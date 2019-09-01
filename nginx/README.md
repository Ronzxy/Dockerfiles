Nginx
=====

Auto build nginx and create nginx docker image in debian.

# Build:
```shell
git clone https://github.com/skygangsta/Dockerfile.git
cd Dockerfile/nginx
chmod 755 builder
./builder
```

# Docker
```shell
docker run --name nginx \
-h nginx \
-p 80:80 \
-p 443:443 \
-v /home/storage/run/docker/nginx/conf:/usr/nginx/conf \
-v /home/storage/run/docker/nginx/html:/usr/nginx/html \
-v /home/storage/run/docker/nginx/cert:/usr/nginx/cert \
-v /home/storage/run/docker/nginx/logs:/var/log/nginx \
--cpu-shares=512 --memory=256m --memory-swap=0 \
--restart=always \
--oom-kill-disable \
-it -d skygangsta/nginx:1.16.1-alpine

```

# Podman

```sh

mkdir -p /home/storage/run/docker/nginx/{conf,html,cert,logs}
docker run --name nginx \
-h nginx \
-p 80:80 \
-p 443:443 \
-v /home/storage/run/docker/nginx/conf:/usr/nginx/conf:z \
-v /home/storage/run/docker/nginx/html:/usr/nginx/html:z \
-v /home/storage/run/docker/nginx/cert:/usr/nginx/cert:z \
-v /home/storage/run/docker/nginx/logs:/var/log/nginx:z \
--cpu-shares=512 --memory=2G --memory-swap=0 \
--oom-kill-disable \
-it -d skygangsta/nginx:1.16.1-alpine

```
