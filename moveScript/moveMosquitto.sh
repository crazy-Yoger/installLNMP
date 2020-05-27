#!/bin/sh
echo "Please enter mosquitto path:"
read path

path="$path/mosquitto_data"
if [ -d ${path} ];then
    echo now mysql path $path
else
#创建新的持久化目录
mkdir $path/mosquitto_data
mkdir $path/mosquitto_data/mosquitto
chown -R mosquitto:mosquitto $path/mosquitto_data/mosquitto

#修改数据存放路径
sed -i "s/persistence_location \/var\/lib\/mosquitto/persistence_location \\$path\/mosquitto_data\/mosquitto/g" /etc/mosquitto/mosquitto.conf

#重启mosquitto服务
systemctl restart mosquitto

fi




