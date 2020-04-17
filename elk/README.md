# ELK

```sh
### Elasticsearch

docker run --name elasticsearch \
    -h elasticsearch \
    -p 9200:9200 \
    -p 9300:9300 \
    -v elasticsearch-conf:/usr/elasticsearch/config:rw,z \
    -v elasticsearch-logs:/usr/elasticsearch/logs:rw,z \
    -v elasticsearch-data:/usr/elasticsearch/data:rw,z \
    -e DISCOVERY_TYPE=single-node \
    --cpu-shares=512 --memory=2G --memory-swap=8G \
    --restart=always \
    -it -d docker.ronzxy.com/elasticsearch:7.6.2


### Kibana

docker run --name kibana \
    -h kibana \
    -p 5601:5601 \
    -v kibana-conf:/usr/kibana/config:rw,z \
    -v kibana-logs:/usr/kibana/logs:rw,z \
    -v kibana-data:/var/lib/kibana:rw,z \
    -e SERVER_NAME=kibana \
    -e SERVER_HOST=0.0.0.0 \
    -e ELASTICSEARCH_HOSTS=http://172.17.0.1:9200 \
    --cpu-shares=512 --memory=1G --memory-swap=4G \
    --restart=on-failure \
    -it -d docker.ronzxy.com/kibana:7.6.2

### Logstash

# docker run --name logstash \
#     -h logstash \
#     -p 5044:5044 \
#     -p 9600:9600 \
#     -v logstash-conf:/usr/logstash/config:rw,z \
#     -v logstash-logs:/usr/logstash/logs:rw,z \
#     -v logstash-data:/var/lib/logstash:rw,z \
#     -e ELASTICSEARCH_HOSTS=http://172.17.0.1:9200 \
#     --cpu-shares=512 --memory=1G --memory-swap=4G \
#     --restart=on-failure \
#     -it -d docker.ronzxy.com/logstash:7.6.2

### Filebeat

docker run --name filebeat \
    -h filebeat-payment \
    -v filebeat-conf:/usr/filebeat/config:rw,z \
    -v filebeat-logs:/var/log/filebeat:rw,z \
    -v filebeat-data:/var/lib/filebeat:rw,z \
    -v /mnt/data:/data:ro,z \
    -e ELASTICSEARCH_HOSTS=http://10.31.178.100:9200 \
    -e KIBANA_HOSTS=http://10.31.178.100:5601 \
    -e NODE_NAME=payment \
    -e SETUP_ILM_OVERWRITE=true \
    -e SETUP_ILM_POLICY_MAX_SIZE=50GB \
    -e SETUP_ILM_ROLLOVER_ALIAS=payment-178-143 \
    -e INPUT_FILE_PATTERN_LIST='/data/*/*/logs/*' \
    -e OUTPUT_FIELDS="server: payment,ip: 10.31.178.144" \
    --cpu-shares=512 --memory=1G --memory-swap=4G \
    --restart=on-failure \
    -it -d docker.ronzxy.com/filebeat:7.6.2

```

## 常见问题解决

###　创建定义策略

```sh
curl -X PUT "localhost:9200/_ilm/policy/datastream_policy" -H 'Content-Type: application/json' -d'
{
  "policy": {                       
    "phases": {
      "hot": {                      
        "actions": {
          "rollover": {             
            "max_size": "50GB",
            "max_age": "30d"，
            "max_docs": ""
          }
        }
      },
      "delete": {
        "min_age": "90d",           
        "actions": {
          "delete": {}              
        }
      }
    }
  }
}
'
```

其中rollover中配置归档策略，目前支持3中策略，分别是max_docs、max_size、max_age（请关注、具体后续内容介绍），
其中的任何一个条件满足时都会触发索引的归档操作，并删除归档90天后的索引文件（其中delete属于phrase，这个也会在后面内容介绍）。

```sh
# Resolv : blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];
PUT /funpay-178-144-2020.01.07-000001/_settings
{
  "index.blocks.read_only_allow_delete": null
}
```
