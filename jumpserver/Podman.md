# 创建 Jumpserver POD

Create and run jumpserver under POD

### Create POD

```sh

podman pod create --name jumpserver \
-p 80:80/tcp \
-p 443:443/tcp \
-p 2222:2222/tcp

```

### Create postgres container

```sh
mkdir -p /home/storage/run/docker/jumpserver/postgres
podman run --pod jumpserver --name jumpserver-postgres \
    -h postgres \
    -v /home/storage/run/docker/jumpserver/postgres:/var/lib/postgres:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=1024 --memory=8G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d postgres:11.5-alpine

podman exec -it jumpserver_postgres psql -U postgres -c "
CREATE USER jumpserver WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'Abc123';
"
podman exec -it jumpserver_postgres psql -U postgres -c "
CREATE DATABASE jumpserver
    WITH 
    OWNER = jumpserver
    ENCODING = 'UTF8'
    LC_COLLATE = 'zh_CN.UTF-8'
    LC_CTYPE = 'zh_CN.UTF-8'
    CONNECTION LIMIT = -1;
"
```

### Create redis container

```sh

mkdir -p /home/storage/run/docker/jumpserver/redis
podman run --pod jumpserver --name jumpserver-redis \
    -h redis \
    -v /home/storage/run/docker/jumpserver/redis:/var/lib/redis:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    --cpu-shares=512 --memory=8G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -t -i -d redis:5.0.5

```

### Create nginx container

```sh
mkdir -p /home/storage/run/docker/jumpserver/nginx/{conf,html,cert,logs}

podman run --pod jumpserver --name jumpserver-nginx \
-h nginx \
-v /home/storage/run/docker/jumpserver/nginx/conf:/usr/nginx/conf:rw,z \
-v /home/storage/run/docker/jumpserver/nginx/html:/usr/nginx/html:rw,z \
-v /home/storage/run/docker/jumpserver/nginx/cert:/usr/nginx/cert:rw,z \
-v /home/storage/run/docker/jumpserver/nginx/logs:/var/log/nginx:rw,z \
-v /etc/resolv.conf:/etc/resolv.conf:ro,z \
--cpu-shares=512 --memory=2G --memory-swap=0 \
--restart=always \
--oom-kill-disable \
-it -d skygangsta/nginx:1.16.1-alpine

```

### Create jumpserver core container

```sh
mkdir -p /home/storage/run/docker/jumpserver/nginx/html/jumpserver

podman run --pod jumpserver --name jumpserver-core \
    -h jumpserver \
    -v /home/storage/run/docker/jumpserver/nginx/html/jumpserver:/usr/jumpserver/data:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e SECRET_KEY=5uiP2v17s67abXEGFoc6c9NC5dla0Z5BbyTBB0xqRhfLokZ6Jh \
    -e BOOTSTRAP_TOKEN=lTfjwIKagqSyx5NK \
    -e DB_ENGINE=postgresql \
    -e DB_HOST=localhost \
    -e DB_PORT=5432 \
    -e DB_NAME=jumpserver \
    -e DB_USER=jumpserver \
    -e DB_PASSWORD=Abc123 \
    -e REDIS_HOST=localhost \
    -e REDIS_PORT=6379 \
    -e REDIS_PASSWORD= \
    --cpu-shares=512 --memory=4G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d jumpserver:1.5.2

```

# Create koko and guacamole container

```sh

JUMPSERVER_SERVER=http://localhost:8080
BOOTSTRAP_TOKEN=lTfjwIKagqSyx5NK

podman run --pod jumpserver --name jumpserver-koko \
    -h koko-server \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e CORE_HOST=${JUMPSERVER_SERVER} \
    -e BOOTSTRAP_TOKEN=${BOOTSTRAP_TOKEN} \
    --cpu-shares=512 --memory=4G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d jumpserver-koko:1.5.2

podman run --pod jumpserver --name jumpserver-guacamole \
    -h guacamole-server \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -e JUMPSERVER_SERVER=${JUMPSERVER_SERVER} \
    -e BOOTSTRAP_TOKEN=${BOOTSTRAP_TOKEN} \
    --cpu-shares=512 --memory=4G --memory-swap=0 \
    --restart=always \
    --oom-kill-disable \
    -it -d jumpserver-guacamole:1.5.2

```


