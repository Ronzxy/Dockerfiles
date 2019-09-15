# Jumpserver

Build and create jumpserver docker image from the alpine 3.9 because it requires python 3.6.

# Build

```sh

git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/jumpserver
chmod 755 builder
./builder image

```

# Usage

```sh

mkdir -p /home/storage/run/docker/nginx/html/jumpserver

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name jumpserver-core \
    -h jumpserver \
    -p 8080:8080 \
    -v /home/storage/run/docker/nginx/html/jumpserver:/usr/jumpserver/data:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e SECRET_KEY=5uiP2v17s67abXEGFoc6c9NC5dla0Z5BbyTBB0xqRhfLokZ6Jh \
    -e BOOTSTRAP_TOKEN=lTfjwIKagqSyx5NK \
    -e DB_ENGINE=postgresql \
    -e DB_HOST=172.17.0.1 \
    -e DB_PORT=54321 \
    -e DB_NAME=jumpserver \
    -e DB_USER=jumpserver \
    -e DB_PASSWORD=Abc123 \
    -e REDIS_HOST=172.17.0.1 \
    -e REDIS_PORT=6379 \
    -e REDIS_PASSWORD= \
    --cpu-shares=512 --memory=4G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d jumpserver:1.5.2

```

# 安装 KOKO 和 Guacamole

```sh

JUMPSERVER_SERVER=http://172.17.0.1:8080
BOOTSTRAP_TOKEN=lTfjwIKagqSyx5NK

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name jumpserver-koko \
    -h koko-server \
    -p 2222:2222 \
    -p 5000:5000 \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e CORE_HOST=${JUMPSERVER_SERVER} \
    -e BOOTSTRAP_TOKEN=${BOOTSTRAP_TOKEN} \
    --cpu-shares=512 --memory=4G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d jumpserver-koko:1.5.2

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name jumpserver-guacamole \
    -h guacamole-server \
    -p 8081:8081 \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e JUMPSERVER_SERVER=${JUMPSERVER_SERVER} \
    -e BOOTSTRAP_TOKEN=${BOOTSTRAP_TOKEN} \
    --cpu-shares=512 --memory=4G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d jumpserver-guacamole:1.5.2

```
