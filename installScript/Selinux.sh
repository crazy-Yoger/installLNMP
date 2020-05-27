#!/bin/sh
#关闭selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux