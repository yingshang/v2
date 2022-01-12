FROM ubuntu:18.04

RUN apt update -y
RUN apt install -y wget unzip nginx vim 
RUN mkdir /opt/v2ray && cd /opt/v2ray && wget https://github.com/v2fly/v2ray-core/releases/download/v5.0.2/v2ray-linux-64.zip && unzip v2ray-linux-64.zip
COPY config.json /opt/v2ray
COPY nginx.conf /etc/nginx/
RUN mkdir /var/log/v2ray
RUN cd /root &&  openssl rand -writerand .rnd
RUN cd /opt && openssl genrsa -out server.key 1024   &&  openssl req -new -key server.key -out server.csr --batch && openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt 

RUN uuid=$(cat /proc/sys/kernel/random/uuid) && echo 'v2密码: '${uuid}'' && sed -i 's/password/'${uuid}'/g' /opt/v2ray/config.json
RUN uri=$(cat /proc/sys/kernel/random/uuid  | md5sum |cut -c 1-20) && echo 'nginx 路径: '${uri}'' && sed -i 's/uri/'${uri}'/g' /opt/v2ray/config.json && sed -i 's/uri/'${uri}'/g' /etc/nginx/nginx.conf

ENTRYPOINT export V2RAY_VMESS_AEAD_FORCED=false && nginx && /opt/v2ray/v2ray run
