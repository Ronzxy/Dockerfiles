# Rsyslog

Create rsyslog docker image from alpine edge.

# Usage:
```shell
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/rsyslog
chmod 755 builder
./builder image
```

# 创建容器
```shell

mkdir -p /home/storage/run/docker/rsyslog/{conf,logs}

CONTAINER_ENGINE=docker
${CONTAINER_ENGINE} run --name rsyslog \
    -h rsyslog.container.cn \
    -p 5140:514/tcp \
    -p 5140:514/udp \
    -v /home/storage/run/docker/rsyslog/conf:/etc/rsyslog.d:rw,z \
    -v /home/storage/run/docker/rsyslog/logs:/var/log:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=512 --memory=1G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/rsyslog:alpine-edge

```
# 测试 
echo netcat:"Nginx test log" | nc -u -w 1 localhost 5140

# 手动轮换日志文件
docker exec -it rsyslog logrotate -f /etc/logrotate.conf
