#!/usr/bin/env bash

join_args=$1

#####################################

echo "staring install docker"

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

echo "install docker version $(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')"
apt-get install docker-compose docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

echo "install docker end"


#####################################

echo "starting install <kubeadm>"
cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://mirrors.ustc.edu.cn/kubernetes/apt/ kubernetes-xenial main
EOF

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3746C208A7317B0F

apt-get update && apt-get install -y kubeadm

echo "install <kubeadm> end"


#####################################

echo "pull k8s node image"
images=(kube-proxy-amd64:v1.9.0 pause-amd64:3.0)
for imageName in ${images[@]} ; do
  docker pull mirrorgooglecontainers/$imageName
  docker tag mirrorgooglecontainers/$imageName gcr.io/google_containers/$imageName
done

docker pull quay.io/coreos/flannel:v0.9.1-amd64


#####################################

echo "join k8s cluster"

kubeadm join $join_args