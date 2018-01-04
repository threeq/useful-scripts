#!/usr/bin/env bash

fail() {
	echo "$*"
	exit
}

echo "install k8s node on ubuntu"
echo
echo

join_args=$1

#####################################

echo "staring install docker"

apt-get remove docker docker-engine docker.io
apt-get autoremove -y
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common || fail ""

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

echo "install docker version $(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')"
# apt-get install -y docker-compose docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
apt-get install -y docker-compose docker-ce

docker version || fail "docker install error" 


curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://2f19a520.m.daocloud.io
systemctl restart docker

echo "install docker end"


#####################################

echo "starting install <kubeadm>"
cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://mirrors.ustc.edu.cn/kubernetes/apt/ kubernetes-xenial main
EOF

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3746C208A7317B0F

apt-get update && apt-get install -y kubeadm

kubeadm --version || fail "kubeadm install error"

echo "install <kubeadm> end"


#####################################

echo "pull k8s node image"
images=(kube-proxy-amd64:v1.9.0 pause-amd64:3.0)
for imageName in ${images[@]} ; do
  docker pull mirrorgooglecontainers/$imageName
  docker tag mirrorgooglecontainers/$imageName gcr.io/google_containers/$imageName
done

#docker pull quay.io/coreos/flannel:v0.9.1-amd64


#####################################

swapoff -a

cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
vm.swappiness=0
EOF

sysctl -p /etc/sysctl.d/k8s.conf

# xxx
systemctl stop firewalld
systemctl disable firewalld

systemctl stop ufw
systemctl disable ufw

setenforce 0
mkdir -p /etc/selinux
cat > /etc/selinux/config << EOF
SELINUX=disabled
EOF

#####################################

echo "join k8s cluster"

#kubeadm join $join_args
