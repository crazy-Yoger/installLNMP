#!/bin/sh
path="/var/lib/redis"
if [ -d ${path} ];then
    echo "Please enter redis path:"
read path

newPath="$path/redis_data"
if [ -d ${newPath} ];then
    echo now redis path is $newPath
else
#创建新的持久化目录
mkdir $newPath/redis_data

#给redis文件夹赋权限
chown -R redis:redis $newPath/redis_data

#复制/var/lib/redis至新redis文件目录
cp -a /var/lib/redis $newPath/redis_data

#修改redis数据持久化路径
sed -i "s/dir \/var\/lib\/redis/dir \\$newPath\/redis_data\/redis/g" /etc/redis.conf

#启动redis服务
systemctl start redis
fi

else
    echo "redis path error:"
fi



