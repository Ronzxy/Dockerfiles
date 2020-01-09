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

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name redis \
    -p 6379:6379 \
    -v redis-data:/var/lib/redis:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=512 --memory=8G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/redis:5.0.7

```
