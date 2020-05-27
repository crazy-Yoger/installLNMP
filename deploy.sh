#!/bin/sh

#使用阿里源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum update -y
yum install -y epel-release

yum clean all
yum makecache

yum install -y yum-utils

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

#安装node
curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -
yum install -y nodejs
npm install -g yarn
npm install -g typescript

#安装docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
usermod -aG docker $(whoami)

systemctl start docker.service
systemctl enable docker.service

#安装mosquitto
yum install -y mosquitto

systemctl start mosquitto
systemctl enable mosquitto

cat>>/etc/mosquitto/mosquitto.conf<<"EOF"
persistent_client_expiration 14d # 持久化多长时间后未被消费则过期数据
persistence true #配置持久化
max_inflight_messages 0 # 队列长度无限制

# 默认端口 1883，如果需要同时监听 WebSocket 在配置文件最后增加如下内容
listener 1883 # this will listen for mqtt on tcp
listener 8080 # this will expect websockets connections
protocol websockets
EOF

#安装elasticsearch
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat>/etc/yum.repos.d/elastic-7x.repo<<"EOF"
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
# 速度慢切换到清华源
baseurl=https://mirrors.tuna.tsinghua.edu.cn/elasticstack/yum/elastic-7.x/
# baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install -y elasticsearch

sed -i "s/-Xms1g/-Xms2g/g"  /etc/elasticsearch/jvm.options
sed -i "s/-Xmx1g/-Xmx2g/g"   /etc/elasticsearch/jvm.options

cat>>/etc/elasticsearch/elasticsearch.yml<<"EOF"
http.host: 0.0.0.0
bootstrap.memory_lock: true
EOF

systemctl daemon-reload
systemctl start elasticsearch.service
systemctl enable elasticsearch.service

#安装kibana
yum install -y kibana

systemctl start kibana.service
systemctl enable kibana.service

cat>>/etc/kibana/kibana.yml<<"EOF"
server.host: 0.0.0.0
elasticsearch.hosts: ["http://localhost:9200"]
EOF

#安装filebeat
yum install -y filebeat

cat>/etc/filebeat/filebeat.yml<<"EOF"
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/www/html/laravel-6.0-boilerplate/storage/logs/*.log
  multiline.pattern: ^\[[0-9]{4}-[0-9]{2}-[0-9]{2}
  multiline.negate: true
  multiline.match: after
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.ilm.enabled: false
setup.template.name: "monolog"
setup.template.pattern: "monolog-*"
setup.template.settings:
  index.number_of_shards: 1
setup.kibana:
output.elasticsearch:
  hosts: ["www.joydata.com:9200"]
  index: "monolog-%{[agent.version]}-%{+yyyy.MM.dd}"
  username: "monolog"
  password: "joydata"

EOF

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

#关闭selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux

#重启系统
reboot

