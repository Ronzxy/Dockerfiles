# php

Build and create php docker image from the alpine edge.

# Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/php
chmod 755 builder
./builder image
```

# Usage

```sh
docker run --name php \
-p 8880:80 \
-p 8443:443 \
-v /home/storage/run/docker/php/nginx:/usr/nginx/conf:rw,z \
-v /home/storage/run/docker/php/html:/usr/nginx/html:rw,z \
-v /home/storage/run/docker/php/cert:/usr/nginx/cert:rw,z \
-v /home/storage/run/docker/php/logs:/var/log/nginx:rw,z \
-v /home/storage/run/docker/php/conf:/etc/php:rw,z \
--cpu-shares=512 --memory=512m --memory-swap=0 \
--restart=always \
--oom-kill-disable \
-d skygangsta/php:7.3.9-alpine
```
