#!/bin/sh
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

#修改elasticsearch配置文件
if grep -q "http.host: 0.0.0.0" /etc/elasticsearch/elasticsearch.yml
then
    echo elasticsearch is exist!
else
cat>>/etc/elasticsearch/elasticsearch.yml<<"EOF"
http.host: 0.0.0.0
bootstrap.memory_lock: true
EOF

systemctl daemon-reload
systemctl start elasticsearch.service
systemctl enable elasticsearch.service

fi

#安装kibana
yum install -y kibana

if grep -q "server.host: 0.0.0.0" /etc/kibana/kibana.yml
then
    echo kibana is exist!
else
cat>>/etc/kibana/kibana.yml<<"EOF"
server.host: 0.0.0.0
elasticsearch.hosts: ["http://localhost:9200"]
EOF

systemctl start kibana.service
systemctl enable kibana.service

fi

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