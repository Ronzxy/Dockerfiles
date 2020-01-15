# PostgreSQL

Build and create jenkins docker image from the alpine edge.

### Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/jenkins
chmod 755 builder
./builder image
```

### Usage

```sh

CONTAINER_ENGINE=docker

${CONTAINER_ENGINE} run --name jenkins \
    -h jenkins.erayun.cn \
    -p 8080:8080 \
    -v jenkins-data:/var/lib/jenkins:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=1024 --memory=1G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d skygangsta/jenkins:2.190.1

```
