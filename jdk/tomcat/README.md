# Tomcat

Build and create tomcat docker image from the jdk image.

### Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfile/jdk/tomcat
chmod 755 builder
./builder image
```

### Usage

```sh
docker run --name tomcat \
    -p 8080:8080 \
    -v tomcat-conf:/usr/tomcat/conf:rw,z \
    -v tomcat-logs:/usr/tomcat/logs:rw,z \
    -v tomcat-apps:/usr/tomcat/webapps:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e CATALINA_OUT="catalina.out.%Y-%m-%d-%H" \
    --cpu-shares=512 --memory=1G --memory-swap=0 \
    --restart=on-failure \
    -it -d skygangsta/tomcat:8.5-8u231
```
