# Nginx

Build and create nginx docker image from the alpine edge.

## Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/nginx
chmod 755 builder
./builder image
```

## Usage

```sh

CONTAINER_NAME=nginx-waf
IMAGE_NAME=nginx-waf:1.16.1-alpine
mkdir -p /home/storage/run/docker/${CONTAINER_NAME}/{conf,html,cert,logs}

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name ${CONTAINER_NAME} \
-h nginx \
-p 80:80 \
-p 443:443 \
-v /home/storage/run/docker/${CONTAINER_NAME}/conf:/usr/nginx/conf:rw,z \
-v /home/storage/run/docker/${CONTAINER_NAME}/html:/usr/nginx/html:rw,z \
-v /home/storage/run/docker/${CONTAINER_NAME}/cert:/usr/nginx/cert:rw,z \
-v /home/storage/run/docker/${CONTAINER_NAME}/logs:/var/log/nginx:rw,z \
-v /etc/resolv.conf:/etc/resolv.conf:ro,z \
--cpu-shares=512 --memory=256m --memory-swap=0 \
--restart=always \
--oom-kill-disable \
-it -d skygangsta/${IMAGE_NAME}

```
