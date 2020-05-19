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

docker run --name jenkins \
    -h jenkins.ronzxy.com \
    -p 8080:8080 \
    -v jenkins-data:/usr/jenkins/data:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=1024 --memory=1G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d docker.ronzxy.com/jenkins:2.222.3-with-openjdk11

```

/usr/maven/bin/mvn clean -Dmaven.test.skip=true package -P test
