# Nginx

Build and create nginx docker image from the alpine image.

## Build

```sh
git clone https://github.com/skygangsta/Dockerfiles.git
cd Dockerfiles/nginx
chmod 755 builder
./builder image
```

## Usage

```sh

CONTAINER_NAME=nginx
# IMAGE_NAME=docker.ronzxy.com/nginx:1.18.0
IMAGE_NAME=docker.ronzxy.com/nginx:1.18.0-with-modsecurity

docker run --name ${CONTAINER_NAME} \
-h nginx \
-p 80:80 \
-p 443:443 \
-v ${CONTAINER_NAME}-conf:/usr/nginx/conf:rw,z \
-v ${CONTAINER_NAME}-html:/usr/nginx/html:rw,z \
-v ${CONTAINER_NAME}-cert:/usr/nginx/cert:rw,z \
-v ${CONTAINER_NAME}-logs:/usr/nginx/logs:rw,z \
-v /etc/resolv.conf:/etc/resolv.conf:ro,z \
-v /etc/timezone:/etc/timezone:ro,z \
-v /etc/localtime:/etc/localtime:ro,z \
--cpu-shares=512 --memory=256m --memory-swap=0 \
--restart=on-failure \
--oom-kill-disable \
-it -d ${IMAGE_NAME}

```

## Podman

### Container

```sh

CONTAINER_NAME=nginx
IMAGE_NAME=docker.ronzxy.com/nginx:1.18.0
# IMAGE_NAME=docker.ronzxy.com/nginx:1.18.0-with-modsecurity
# mkdir -p /home/storage/run/docker/${CONTAINER_NAME}/{conf,html,cert,logs}

podman \
run --name ${CONTAINER_NAME} \
-h nginx \
-p 80:80 \
-p 443:443 \
-v ${CONTAINER_NAME}-conf:/usr/nginx/conf:rw,z \
-v ${CONTAINER_NAME}-html:/usr/nginx/html:rw,z \
-v ${CONTAINER_NAME}-cert:/usr/nginx/cert:rw,z \
-v ${CONTAINER_NAME}-logs:/usr/nginx/logs:rw,z \
-v /etc/resolv.conf:/etc/resolv.conf:ro,z \
-v /etc/timezone:/etc/timezone:ro,z \
-v /etc/localtime:/etc/localtime:ro,z \
--cpu-shares=512 --memory=256m --memory-swap=0 \
--restart=on-failure \
--oom-kill-disable \
-it -d ${IMAGE_NAME}

```

### Systemd

```sh
# setsebool -P container_manage_cgroup on
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

```


## Configuration

### IF 判断条件

#### 正则表达式匹配

变量名 | 定义
----- | -----
==    | 等值比较;
~     | 与指定正则表达式模式匹配时返回“真”，判断匹配与否时区分字符大小写；
~*    | 与指定正则表达式模式匹配时返回“真”，判断匹配与否时不区分字符大小写；
!~    | 与指定正则表达式模式不匹配时返回“真”，判断匹配与否时区分字符大小写；
!~*   | 与指定正则表达式模式不匹配时返回“真”，判断匹配与否时不区分字符大小写；


#### 文件及目录判断

变量名 | 定义
----- | -----
-f, !-f | 判断指定的路径是否为存在且为文件；
-d, !-d | 判断指定的路径是否为存在且为目录；
-e, !-e | 判断指定的路径是否存在，文件或目录均可；
-x, !-x | 判断指定路径的文件是否存在且可执行；

#### 判断客户端地址

```conf

if ($remote_addr !~* ^(172)\.(11)\.(1)\.(11)$) {
    return 444;
}

```

#### 通过 IP 地址限制访问

Nginx 可以基于指定的客户端 IP 地址或地址段允许或拒绝访问。在 server 块中使用 allow 或 deny 指令可以允许或拒绝访问：

```conf
server {
    listen 80;

    deny   192.168.0.0/24;
    allow  192.168.1.0/24;
    allow  2001:0db8::/32;
    deny   all;
}
```

#### 常用变量


变量名 | 定义
----- | -----
$arg_PARAMETER | GET请求中变量名PARAMETER参数的值。
$args | 这个变量等于GET请求中的参数。例如，foo=123&bar=blahblah;这个变量只可以被修改
$binary_remote_addr | 二进制码形式的客户端地址。
$body_bytes_sent | 传送页面的字节数
$content_length | 请求头中的Content-length字段。
$content_type | 请求头中的Content-Type字段。
$cookie_COOKIE | cookie COOKIE的值。
$document_root | 当前请求在root指令中指定的值。
$document_uri | 与$uri相同。
$host | 请求中的主机头(Host)字段，如果请求中的主机头不可用或者空，则为处理请求的server名称(处理请求的server的server_name指令的值)。值为小写，不包含端口。
$hostname | 机器名使用 gethostname系统调用的值
$http_HEADER | HTTP请求头中的内容，HEADER为HTTP请求中的内容转为小写，-变为_(破折号变为下划线)，例如：$http_user_agent(Uaer-Agent的值);
$sent_http_HEADER | HTTP响应头中的内容，HEADER为HTTP响应中的内容转为小写，-变为_(破折号变为下划线)，例如： $sent_http_cache_control, $sent_http_content_type…;
$is_args | 如果$args设置，值为"?"，否则为""。
$limit_rate | 这个变量可以限制连接速率。
$nginx_version | 当前运行的nginx版本号。
$query_string | 与$args相同。
$remote_addr | 客户端的IP地址。
$remote_port | 客户端的端口。
$remote_user | 已经经过Auth Basic Module验证的用户名。
$request_filename | 当前连接请求的文件路径，由root或alias指令与URI请求生成。
$request_body | 这个变量（0.7.58+）包含请求的主要信息。在使用proxy_pass或fastcgi_pass指令的location中比较有意义。
$request_body_file | 客户端请求主体信息的临时文件名。
$request_completion | 如果请求成功，设为"OK"；如果请求未完成或者不是一系列请求中最后一部分则设为空。
$request_method | 这个变量是客户端请求的动作，通常为GET或POST。包括0.8.20及之前的版本中，这个变量总为main request中的动作，如果当前请求是一个子请求，并不使用这个当前请求的动作。
$request_uri | 这个变量等于包含一些客户端请求参数的原始URI，它无法修改，请查看$uri更改或重写URI。
$scheme | 所用的协议，比如http或者是https，比如rewrite ^(.+)$ $scheme://example.com$1 redirect;
$server_addr | 服务器地址，在完成一次系统调用后可以确定这个值，如果要绕开系统调用，则必须在listen中指定地址并且使用bind参数。
$server_name | 服务器名称。
$server_port | 请求到达服务器的端口号。
$server_protocol | 请求使用的协议，通常是HTTP/1.0或HTTP/1.1。
$uri | 请求中的当前URI(不带请求参数，参数位于args)，不同于浏览器传递的args)，不同于浏览器传递的args)，不同于浏览器传递的request_uri的值，它可以通过内部重


#### ModSecurity 白名单配置

```conf
SecRule REMOTE_ADDR "@streq 192.168.1.1" \
phase:1,t:none,nolog,allow
SecRule REMOTE_ADDR "@rx ^192\.168\.1\.(1|5|10)$" \
phase:1,t:none,nolog,allow
SecRule REMOTE_ADDR "@streq 192.168.1.1" \
phase:1,t:none,nolog,pass,ctl:ruleEngine=DetectionOnly
```

