# 创建 ELK POD

Create and run ELK under POD

## Create POD

### Create ELK POD

```sh
podman pod create --name elk \
-p 9200:9200/tcp \
-p 9300:9300/tcp \
-p 5601:5601/tcp

```

## Create container

### Create Elasticsearch container

```sh
mkdir -p /home/storage/run/docker/elk/elasticsearch/{conf,data,logs}
chown -R 999:999 /home/storage/run/docker/elk/elasticsearch
podman run \
    --pod elk \
    --name elk-elasticsearch \
    -v /home/storage/run/docker/elk/elasticsearch/conf:/usr/elasticsearch/config:rw,z \
    -v /home/storage/run/docker/elk/elasticsearch/logs:/usr/elasticsearch/logs:rw,z \
    -v /home/storage/run/docker/elk/elasticsearch/data:/usr/elasticsearch/data:rw,z \
    -e DISCOVERY_TYPE=single-node \
    --cpu-shares=1024 --memory=26G --memory-swap=0 \
    --restart=always \
    -it -d docker.ronzxy.com/elasticsearch:7.6.2

```

### Create Kibana container
```sh
mkdir -p /home/storage/run/docker/elk/kibana/{conf,data,logs}
chown -R 999:999 /home/storage/run/docker/elk/kibana
podman run \
    --pod elk \
    --name elk-kibana \
    -v /home/storage/run/docker/elk/kibana/conf:/usr/kibana/config:rw,z \
    -v /home/storage/run/docker/elk/kibana/logs:/usr/kibana/logs:rw,z \
    -v /home/storage/run/docker/elk/kibana/data:/var/lib/kibana:rw,z \
    -e SERVER_NAME=kibana \
    -e SERVER_HOST=0.0.0.0 \
    -e ELASTICSEARCH_HOSTS=http://localhost:9200 \
    --cpu-shares=512 --memory=2G --memory-swap=4G \
    --restart=on-failure \
    -it -d docker.ronzxy.com/kibana:7.6.2

```


