#!/bin/sh
#安装mosquitto
yum install -y mosquitto

if grep -q "protocol websockets" /etc/mosquitto/mosquitto.conf
then
    echo mosquitto is exist!
else
cat>>/etc/mosquitto/mosquitto.conf<<"EOF"
persistent_client_expiration 14d # 持久化多长时间后未被消费则过期数据
persistence true #配置持久化
persistence_location /var/lib/mosquitto/ #持久化文件位置
max_inflight_messages 0 # 队列长度无限制


# 默认端口 1883，如果需要同时监听 WebSocket 在配置文件最后增加如下内容
listener 1883 # this will listen for mqtt on tcp
listener 8080 # this will expect websockets connections
protocol websockets

EOF

systemctl start mosquitto
systemctl enable mosquitto

fi

path="/var/lib/mosquitto"
if [ -d ${path} ];then
    echo mqtt is exist!
else
mkdir /var/lib/mosquitto
chown -R mosquitto:mosquitto /var/lib/mosquitto
fi


