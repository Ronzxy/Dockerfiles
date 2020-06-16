# etcd

Build and create etcd docker image from the alpine edge.

### Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/etcd
chmod 755 builder
./builder image
```

### Usage

```sh

docker run --name etcd \
    -p 12379-12380:2379-2380 \
    -v etcd-data:/usr/etcd/data:rw,z \
    -v etcd-cert:/usr/etcd/cert:rw,z \
    -v /etc/resolv.conf:/etc/resolv.conf:ro,z \
    -v /etc/timezone:/etc/timezone:ro,z \
    -v /etc/localtime:/etc/localtime:ro,z \
    -e ETCD_LOGGER=zap \
    -e ETCD_DATA_DIR=/usr/etcd/data \
    -e ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379 \
    -e ETCD_ADVERTISE_CLIENT_URLS=http://0.0.0.0:2379 \
    --cpu-shares=512 --memory=512m --memory-swap=0 \
    --restart=on-failure \
    --oom-kill-disable \
    -it -d docker.ronzxy.com/etcd:3.4.9

```

### 命令执行

```sh

ETCD_NAME=etcd
ETCD_VERSION=3.4.9
ETCD_NODE_NAME=etcd-01
ETCD_SERVERS=https://localhost:2379

# 查看健康状态
docker exec ${ETCD_NAME}-v${ETCD_VERSION}-${ETCD_NODE_NAME} /bin/sh -c "
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} endpoint health
"

# 查看群集状态
docker exec ${ETCD_NAME}-v${ETCD_VERSION}-${ETCD_NODE_NAME} /bin/sh -c "
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} member list
"

# 创建root用户并开启授权
docker exec ${ETCD_NAME}-v${ETCD_VERSION}-${ETCD_NODE_NAME} /bin/sh -c "
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} \
role add root
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} \
user add root:Abc123
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} \
user grant-role root root
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} \
auth enable
"

# 创建角色并授权
docker exec ${ETCD_NAME}-v${ETCD_VERSION}-${ETCD_NODE_NAME} /bin/sh -c "
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} --user=root:Abc123 \
role add ronzxy
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} --user=root:Abc123 \
role grant-permission --prefix=true ronzxy readwrite /ronzxy/
"

# 添加用户并授权角色
docker exec ${ETCD_NAME}-v${ETCD_VERSION}-${ETCD_NODE_NAME} /bin/sh -c "
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} --user=root:Abc123 \
user add ronzxy:Abc123
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} --user=root:Abc123 \
user grant-role ronzxy ronzxy
"

# 修改密码
docker exec ${ETCD_NAME}-v${ETCD_VERSION}-${ETCD_NODE_NAME} /bin/sh -c "
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} --user=root:Abc123 \
user passwd ronzxy
"

# 删除用户
docker exec ${ETCD_NAME}-v${ETCD_VERSION}-${ETCD_NODE_NAME} /bin/sh -c "
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} --user=root:Abc123 \
user delete ronzxy
"

# 用户列表
docker exec ${ETCD_NAME}-v${ETCD_VERSION}-${ETCD_NODE_NAME} /bin/sh -c "
etcdctl --cacert=/pki/ca.pem --cert=/pki/etcd.pem --key=/pki/etcd-key.pem \
--endpoints=${ETCD_SERVERS} --user=root:Abc123 \
user list
"

```
