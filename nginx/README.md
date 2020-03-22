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
IMAGE_NAME=docker.ronzxy.com/nginx:1.16.1-with-modsecurity
mkdir -p /home/storage/run/docker/${CONTAINER_NAME}/{conf,html,cert,logs}

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name ${CONTAINER_NAME} \
-h nginx \
-p 80:80 \
-p 443:443 \
-v ${CONTAINER_NAME}-conf:/usr/nginx/conf:rw,z \
-v ${CONTAINER_NAME}-html:/usr/nginx/html:rw,z \
-v ${CONTAINER_NAME}-cert:/usr/nginx/cert:rw,z \
-v ${CONTAINER_NAME}-logs:/usr/nginx/logs:rw,z \
-v /etc/resolv.conf:/etc/resolv.conf:ro,z \
-v /etc/timezone:/etc/timezone:ro,z \
-v /etc/localtime:/etc/localtime:ro,z \
--cpu-shares=512 --memory=256m --memory-swap=0 \
--restart=always \
--oom-kill-disable \
-it -d ${IMAGE_NAME}


# 2
CONTAINER_NAME=nginx
IMAGE_NAME=docker.ronzxy.com/nginx:1.16.1
mkdir -p /home/storage/run/docker/${CONTAINER_NAME}/{conf,html,cert,logs}

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name ${CONTAINER_NAME} \
-h nginx \
-p 8080:80 \
-p 4430:443 \
-v ${CONTAINER_NAME}-conf:/usr/nginx/conf:rw,z \
-v ${CONTAINER_NAME}-html:/usr/nginx/html:rw,z \
-v ${CONTAINER_NAME}-cert:/usr/nginx/cert:rw,z \
-v ${CONTAINER_NAME}-logs:/usr/nginx/logs:rw,z \
-v /etc/resolv.conf:/etc/resolv.conf:ro,z \
-v /etc/timezone:/etc/timezone:ro,z \
-v /etc/localtime:/etc/localtime:ro,z \
--cpu-shares=512 --memory=256m --memory-swap=0 \
--restart=always \
--oom-kill-disable \
-it -d ${IMAGE_NAME}

```
