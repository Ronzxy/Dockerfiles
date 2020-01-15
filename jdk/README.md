# Tomcat

Build and create oracle jdk docker image.

### Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfile/jdk
chmod 755 builder
./builder image
```

### Usage

```sh

docker run --rm \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=512 --memory=1G --memory-swap=0 \
    -it skygangsta/jdk:8u231-alpine \
    java -version
    
```
