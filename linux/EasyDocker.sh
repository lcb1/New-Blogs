#! /bin/bash
#author: lcb
#init time 2019-5-26




yum update -y
yum remove docker  docker-common docker-selinux docker-engine -y
yum install -y yum-utils device-mapper-persistent-data lvm2 -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo -y
yum install docker-ce -y
systemctl start docker
echo {\"registry-mirrors\":[\"https://3tnmkjem.mirror.aliyuncs.com\"]} >> /etc/docker/daemon.json
systemctl restart docker
echo   Complete!
