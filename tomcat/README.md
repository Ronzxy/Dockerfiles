# Tomcat

Build and create tomcat docker image from the openjdk.

### Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfile/tomcat
chmod 755 builder
./builder image
```

### Usage

```sh
# IMAGE_NAME=docker.ronzxy.com/tomcat:8.5.56-with-jdk8u231
# IMAGE_NAME=docker.ronzxy.com/tomcat:8.5.56-with-openjdk8
IMAGE_NAME=docker.ronzxy.com/tomcat:8.5.56-with-adoptjdk8-openj9
MEMORY=1G
docker run --name tomcat \
    -p 8080:8080 \
    -v tomcat-conf:/usr/tomcat/conf:rw,z \
    -v tomcat-logs:/usr/tomcat/logs:rw,z \
    -v tomcat-apps:/usr/tomcat/webapps:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e CATALINA_OPTS="-Xms${MEMORY} -Xmx${MEMORY}" \
    -e CATALINA_OUT="catalina.out.%Y-%m-%d-%H" \
    --cpu-shares=512 --memory=${MEMORY} --memory-swap=0 \
    --restart=on-failure \
    -it -d ${IMAGE_NAME}
```

cat > /usr/lib/systemd/system/nginx.service << EOF
[Unit]
Description = Nginx service with in a Podman container

[Service]
ExecStart = /usr/bin/podman start -a nginx
ExecStop = /usr/bin/podman stop -t 3 nginx
Restart=on-failure
LimitNOFILE=65536
StartLimitInterval=1
RestartSec=10

[Install]
WantedBy = default.target
EOF

systemctl daemon-reload

systemctl enable --now nginx
