#!/usr/bin/env bash

fail() {
	echo "$*"
	exit
}

echo "install k8s node on centos"
echo
echo

join_args=$1

#####################################

echo "staring install docker"

yum remove docker \
          docker-common \
          docker-selinux \
          docker-engine

yum install -y yum-utils python-pip \
  device-mapper-persistent-data \
  lvm2 || fail ""

#yum-config-manager \
#    --add-repo \
#    https://download.docker.com/linux/centos/docker-ce.repo

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast

yum install -y docker-ce docker-compose

curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://2f19a520.m.daocloud.io
systemctl restart docker

docker version || fail "docker install error" 

echo "install docker end"


#####################################

echo "starting install <kubeadm>"
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3746C208A7317B0F

yum install -y kubeadm socat

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

setenforce 0
mkdir -p /etc/selinux
cat > /etc/selinux/config << EOF
SELINUX=disabled
EOF

#####################################

echo "join k8s cluster"

#kubeadm join $join_args
