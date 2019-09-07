# Nginx

Build and create an nginx docker image from the alpine edge.

# Build
```shell
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/nginx
chmod 755 builder
./builder image
```

# Usage
```sh

mkdir -p /home/storage/run/docker/nginx/{conf,html,cert,logs}

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name nginx \
-h nginx \
-p 80:80 \
-p 443:443 \
-v /home/storage/run/docker/nginx/conf:/usr/nginx/conf:rw,z \
-v /home/storage/run/docker/nginx/html:/usr/nginx/html:rw,z \
-v /home/storage/run/docker/nginx/cert:/usr/nginx/cert:rw,z \
-v /home/storage/run/docker/nginx/logs:/var/log/nginx:rw,z \
--cpu-shares=512 --memory=256m --memory-swap=0 \
--restart=always \
--oom-kill-disable \
-it -d skygangsta/nginx:1.16.1-alpine

```
