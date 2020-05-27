#!/bin/sh

#使用阿里源
file="/etc/yum.repos.d/CentOS-Base.repo.backup"

if [ -f ${file} ];then
    echo yum source is ali!
else
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum update -y
yum install -y epel-release

yum clean all
yum makecache

yum install -y yum-utils
fi


#安装php7.3
yum install -y https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-7.rpm
yum-config-manager --enable remi-php73
yum update -y

yum install -y php php-fpm php-mysqlnd php-opcache php-xml php-xmlrpc php-gd php-mbstring php-json php-pecl-zip php-pecl-redis php-pecl-imagick
systemctl start php-fpm.service
systemctl enable php-fpm.service

#安装vim
yum install -y vim

#安装nginx
yum install -y nginx
systemctl start nginx.service
systemctl enable nginx.service

#安装redis
yum install -y redis
#redis持久化
sed -i "s/appendonly no/appendonly yes/g" /etc/redis.conf

systemctl start redis.service
systemctl enable redis.service

#安装libreoffice
yum -y install libreoffice

#安装ntp
yum install -y ntp

systemctl start ntpd.service
systemctl enable ntpd.service

#先安装Python3再安装supervisor
yum install -y python3
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
easy_install supervisor
yum install -y supervisor

systemctl start supervisord.service
systemctl enable supervisord.service

#安装mariadb
path="/var/lib/mysql"
if [ -d ${path} ];then
    echo mysql is exist!
else
yum install -y mariadb-server mariadb

systemctl start mariadb.service
systemctl enable mariadb.service

#安装expect
yum install -y expect
#设置mysql密码
expect -c "
set timeout 10
spawn mysql_secure_installation

expect  \"Enter current password for root (enter for none):\"
send \"\n\"

expect  \"Set root password?\"
send \"Y\n\"

expect  \"New password:\"
send \"joydata\n\"

expect  \"Re-enter new password:\"
send \"joydata\n\"

expect  \"Remove anonymous users?\"
send \"\n\"

expect  \"Disallow root login remotely?\"
send \"\n\"

expect  \"Remove test database and access to it?\"
send \"\n\"

expect  \"Reload privilege tables now?\"
send \"\n\"

expect eof
"

#PHP添加mysql扩展
yum install -y php-mysql

fi

#开放端口
# http
firewall-cmd --zone=public --add-service=http --permanent
# https
firewall-cmd --zone=public --add-service=https --permanent
# ssh
firewall-cmd --zone=public --add-service=ssh --permanent
#mysql 
firewall-cmd --zone=public --add-service=mysql --permanent
#ntp 
firewall-cmd --zone=public --add-service=ntp --permanent
#mqtt 
firewall-cmd --zone=public --add-port=1883/tcp --permanent
#websocket
firewall-cmd --zone=public --add-port=3000/tcp --permanent

firewall-cmd --reload





