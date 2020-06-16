# Redis

Build and create redis docker image from the alpine edge.

### Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/redis
chmod 755 builder
./builder image
```

### Usage

```sh

docker run --name redis \
    -p 6379:6379 \
    -v redis-data:/usr/redis:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    --cpu-shares=512 --memory=512m --memory-swap=0 \
    --restart=on-failure \
    --oom-kill-disable \
    -it -d docker.ronzxy.com/redis:6.0.3

```
