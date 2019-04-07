#! /bin/bash

# docker install 
echo ""
echo "Docker installing..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast
sudo yum install docker-ce
sudo systemctl start docker
sudo systemctl enable docker


# docker-compose install 
echo ""
echo "Docker-Compose installing..."
curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo ""
echo "gradle installing..."
yum install gradle 
