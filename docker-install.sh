#!/bin/bash

#first run "chmod a+x docker-install.sh"
#then run "sudo ./docker-install.sh"

echo 'apt update && apt upgrade'
apt update && apt upgrade
echo 'apt remove docker docker-engine docker.io containerd runc'
apt remove docker docker-engine docker.io containerd runc
echo 'apt install --no-install-recommends apt-transport-https ca-certificates curl gnupg2'
apt install --no-install-recommends apt-transport-https ca-certificates curl gnupg2
echo 'source /etc/os-release'
source /etc/os-release
echo 'curl docker'
curl -fsSL https://download.docker.com/linux/${ID}/gpg | tee /etc/apt/trusted.gpg.d/docker.asc

echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" | tee /etc/apt/sources.list.d/docker.list
echo 'update'
apt update
echo 'apt install docker'
apt install docker-ce docker-ce-cli containerd.io
echo 'usermod'
usermod -aG docker $USER
echo 'daemon.json'
mkdir /etc/docker

touch /etc/docker/daemon.json

echo '{"hosts": ["tcp://0.0.0.0:2375","unix:///var/run/docker.sock"],"insecure-registries" :["dockerproxy-iva.si.francetelecom.fr","dockerhub1.itn.ftgroup"]}' >> /etc/docker/daemon.json
echo 'install docker-compose'
apt-get install docker-compose
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
# Start dockerd in the background
nohup dockerd > /dev/null 2>&1 &
# Wait for dockerd to start
while true
do
  docker ps > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo 'docker is running'
    break
  fi
  sleep 1
done
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
