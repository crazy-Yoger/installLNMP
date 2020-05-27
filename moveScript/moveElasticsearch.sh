#!/bin/sh
path="/var/lib/elasticsearch"
if [ -d ${path} ];then
    echo "Please enter elasticsearch path:"
read path

newPath="$path/elasticsearch_data"
if [ -d ${newPath} ];then
    echo now elasticsearch path is $newPath
else
#创建新的elasticsearch目录
mkdir $newPath/elasticsearch_data

#关闭elasticsearch
systemctl stop elasticsearch
#给elasticsearch文件夹赋权限
chown -R elasticsearch:elasticsearch $newPath/elasticsearch_data

#复制/var/lib/elasticsearch至新elasticsearch文件目录
cp -a /var/lib/elasticsearch $newPath/elasticsearch_data

#修改elasticsearch数据路径
sed -i "s/path.data: \/var\/lib\/elasticsearch/path.data: \\$newPath\/elasticsearch_data\/elasticsearch/g" /etc/elasticsearch/elasticsearch.yml

#启动elasticsearch服务
systemctl start elasticsearch
fi

else
    echo "elasticsearch path error:"
fi


