#!/bin/sh
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

file="/opt/face-detect.tar"
if [ -f ${file} ];then
    docker image load < /opt/face-detect.tar
else
    curl  -C - -L --retry 10 -o /opt/face-detect.tar  http://www.joydata.com/d/face-detect.tar
    docker image load < /opt/face-detect.tar
fi



