# ELK

```sh
### Elsearch
echo "262144" > /proc/sys/vm/max_map_count

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
    -it -d skygangsta/elasticsearch:7.5.1


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
    -it -d skygangsta/kibana:7.5.1

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
#     -it -d skygangsta/logstash:7.5.1

### Filebeat

docker run --name filebeat \
    -h filebeat-payment \
    -v filebeat-conf:/usr/filebeat/config:rw,z \
    -v filebeat-logs:/var/log/filebeat:rw,z \
    -v filebeat-data:/var/lib/filebeat:rw,z \
    -v /mnt/data:/data:ro,z \
    -e ELASTICSEARCH_HOSTS=http://172.31.178.148:9200 \
    -e KIBANA_HOSTS=http://172.31.178.148:5601 \
    -e NODE_NAME=payment \
    -e SETUP_ILM_OVERWRITE=true \
    -e SETUP_ILM_POLICY_MAX_SIZE=50GB \
    -e SETUP_ILM_ROLLOVER_ALIAS=payment-178-143 \
    -e INPUT_FILE_PATTERN_LIST=/data/*/*/logs/* \
    -e OUTPUT_FIELDS="server: payment,ip: 172.31.178.143" \
    --cpu-shares=512 --memory=1G --memory-swap=4G \
    --restart=on-failure \
    -it -d skygangsta/filebeat:7.5.1

```