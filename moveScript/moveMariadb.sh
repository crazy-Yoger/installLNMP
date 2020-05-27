#!/bin/sh
path="/var/lib/mysql"
if [ -d ${path} ];then
    echo "Please enter mysql path:"
read path

newPath="$path/mysql_data"
if [ -d ${newPath} ];then
    echo now mysql path is $newPath
else
#迁移操作
echo "Please enter mariadb path:"
read path

#创建数据文件目录
mkdir $newPath/mysql_data

#关闭数据库
systemctl stop mariadb

#给数据文件赋权限
chown -R mysql:mysql $newPath/mysql_data

#复制/var/lib/mysql至数据文件目录
cp -a /var/lib/mysql $newPath/mysql_data

#修改数据存放路径
sed -i "s/datadir=\/var\/lib\/mysql/datadir=\\$newPath\/mysql_data\/mysql/g" /etc/my.cnf

#启动数据库
systemctl start mariadb
fi

else
    echo "mysql path error:"
fi

