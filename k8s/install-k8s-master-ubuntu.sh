#!/usr/bin/env bash

fail() {
	echo "$*"
	exit
}

echo "install k8s master on ubuntu"
echo
echo

#####################################

echo "staring install docker"

apt-get remove docker docker-engine docker.io
apt-get autoremove -y
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

echo "install docker version $(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')"
# apt-get install -y docker-compose docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
apt-get install -y docker-compose docker-ce

docker version || "docker install error" 

curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://2f19a520.m.daocloud.io
systemctl restart docker

echo "install docker end"


#####################################

echo "starting install <kubelet kubeadm kubectl kubernetes-cni>"
cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://mirrors.ustc.edu.cn/kubernetes/apt/ kubernetes-xenial main
EOF

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3746C208A7317B0F

apt-get update && apt-get install -y kubelet kubeadm kubectl kubernetes-cni

kubeadm --version || fail "kubeadm install error"

echo "install <kubelet kubeadm kubectl kubernetes-cni> end"


#####################################

echo "pull k8s master image"
images=(kube-proxy-amd64:v1.9.0 kube-scheduler-amd64:v1.9.0 kube-controller-manager-amd64:v1.9.0 kube-apiserver-amd64:v1.9.0 etcd-amd64:3.1.10 pause-amd64:3.0 k8s-dns-sidecar-amd64:1.14.7 k8s-dns-kube-dns-amd64:1.14.7 k8s-dns-dnsmasq-nanny-amd64:1.14.7)
for imageName in ${images[@]} ; do
  docker pull mirrorgooglecontainers/$imageName
  docker tag mirrorgooglecontainers/$imageName gcr.io/google_containers/$imageName
done

docker pull quay.io/coreos/flannel:v0.9.1-amd64


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

echo "config kubelet service parameter"


mkdir -p /etc/cni/net.d

cat > /etc/systemd/system/kubelet.service.d/20-pod-infra-image.conf <<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--pod-infra-container-image=mirrorgooglecontainers/pause-amd64:3.0"
EOF

echo "startup kubelet service"

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet

echo """
        可以使用以下命令查看服务启动状态

        journalctl -xeu kubelet

"""


#####################################

echo "init 🉑️k8s master"

export KUBE_REPO_PREFIX=mirrorgooglecontainers
kubeadm init --apiserver-advertise-address=10.105.30.82 --kubernetes-version=v1.9.0 --pod-network-cidr=10.244.0.0/16


#####################################

echo "config kubectl cmd env"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


#####################################

echo "install pod network"

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "k8s node status"
kubectl get nodes