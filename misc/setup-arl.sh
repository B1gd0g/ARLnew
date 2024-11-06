#!/bin/bash

set -e

# 更新系统
echo "更新系统..."
apt update -y
apt upgrade -y

# 安装必要的依赖
echo "安装必要的依赖..."
apt install -y software-properties-common wget curl gnupg2

# 添加 MongoDB 仓库
echo "添加 MongoDB 仓库..."
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/4.2/multiverse/" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

# 添加 RabbitMQ 仓库
echo "添加 RabbitMQ 仓库..."
wget -O- https://dl.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
echo "deb https://dl.bintray.com/rabbitmq/debian buster main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list

# 更新并安装 MongoDB 和 RabbitMQ
echo "安装 MongoDB 和 RabbitMQ..."
apt update -y
apt install -y mongodb-org rabbitmq-server

# 启动服务
echo "启动服务..."
systemctl enable mongodb
systemctl start mongodb
systemctl enable rabbitmq-server
systemctl start rabbitmq-server

# 安装 Python 3.6 和 pip
echo "安装 Python 3.6 和 pip..."
apt install -y python3.6 python3.6-dev python3-pip

# 设置 pip 源
echo "设置 pip 源..."
pip3 install --upgrade pip
pip3 config set global.index-url https://mirrors.adysec.com/language/pypi

# 安装其他工具
echo "安装其他工具..."
apt install -y git nginx fontconfig wqy-microhei-fonts unzip nmap

# 安装 Nuclei
echo "安装 Nuclei..."
wget -c https://github.com/B1gd0g/ARLnew/raw/master/tools/nuclei.zip -O nuclei.zip
unzip nuclei.zip && mv nuclei /usr/local/bin/ && rm -f nuclei.zip
nuclei -ut

# 安装 WIH
echo "安装 WIH..."
wget -c https://github.com/B1gd0g/ARLnew/raw/master/tools/wih/wih_linux_amd64 -O /usr/local/bin/wih
chmod +x /usr/local/bin/wih

# 克隆 ARL 项目
echo "克隆 ARL 项目..."
cd /opt/
if [ ! -d ARLnew ]; then
  git clone https://github.com/B1gd0g/ARLnew
fi

# 安装 ARL 依赖
echo "安装 ARL 依赖..."
cd ARLnew
pip3 install -r requirements.txt

# 下载 ncrack
echo "下载 ncrack..."
wget -c https://github.com/B1gd0g/ARLnew/raw/master/tools/ncrack -O /usr/local/bin/ncrack
chmod +x /usr/local/bin/ncrack

# 下载 ncrack-services
echo "下载 ncrack-services..."
mkdir -p /usr/local/share/ncrack
wget -c https://github.com/B1gd0g/ARLnew/raw/master/tools/ncrack-services -O /usr/local/share/ncrack/ncrack-services

# 下载 GeoLite2 数据库
echo "下载 GeoLite2 数据库..."
mkdir -p /data/GeoLite2
wget -c https://github.com/B1gd0g/ARLnew/raw/master/tools/GeoLite2-ASN.mmdb -O /data/GeoLite2/GeoLite2-ASN.mmdb
wget -c https://github.com/B1gd0g/ARLnew/raw/master/tools/GeoLite2-City.mmdb -O /data/GeoLite2/GeoLite2-City.mmdb

# 配置 RabbitMQ 用户
echo "配置 RabbitMQ 用户..."
rabbitmqctl add_user arl arlpassword
rabbitmqctl add_vhost arlv2host
rabbitmqctl set_user_tags arl arltag
rabbitmqctl set_permissions -p arlv2host arl ".*" ".*" ".*"

echo "安装完成"
