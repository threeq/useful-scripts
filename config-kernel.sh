#!/usr/bin/env bash

fail() {
	echo "$*"
	exit
}

echo "config centos linux"
echo
echo


#####################################

echo "###  config utils"
yum install -y nfs-utils yum-utils sysstat htop

echo "### config kernel"
cat > /etc/sysctl.conf << EOF
kernel.shmmax = 68719476736
kernel.shmall = 2097152
kernel.shmmni = 4096
kernel.msgmnb = 65536
kernel.msgmax = 655360
kernel.sem = 250 32000 100 128
vm.swappiness = 10
fs.file-max = 6815744
fs.aio-max-nr = 1048576

net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 262144
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_mem = 786432 2097152 3145728
net.ipv4.tcp_rmem = 4096 4096 16777216
net.ipv4.tcp_wmem = 4096 4096 16777216
net.ipv4.tcp_max_orphans= 131072
EOF


# cat > /etc/sysctl.conf < EOF
# kernel.sysrq = 0
# kernel.core_uses_pid = 1
# kernel.msgmnb = 65536
# kernel.msgmax = 65536
# kernel.shmmax = 68719476736
# kernel.shmall = 4294967296

# net.core.wmem_default = 8388608
# net.core.rmem_default = 8388608
# net.core.rmem_max = 16777216
# net.core.wmem_max = 16777216
# net.core.netdev_max_backlog = 262144
# net.core.somaxconn = 262144

# net.ipv4.ip_forward = 0
# net.ipv4.ip_local_port_range = 1024 65000
# net.ipv4.conf.default.rp_filter = 1
# net.ipv4.conf.default.accept_source_route = 0
# net.ipv4.tcp_syncookies = 1
# net.ipv4.tcp_max_tw_buckets = 6000
# net.ipv4.tcp_sack = 1
# net.ipv4.tcp_window_scaling = 1
# net.ipv4.tcp_rmem = 4096 87380 4194304
# net.ipv4.tcp_wmem = 4096 16384 4194304
# net.ipv4.tcp_max_orphans = 3276800
# net.ipv4.tcp_max_syn_backlog = 262144
# net.ipv4.tcp_timestamps = 0
# net.ipv4.tcp_synack_retries = 1
# net.ipv4.tcp_syn_retries = 1
# net.ipv4.tcp_tw_recycle = 1
# net.ipv4.tcp_tw_reuse = 1
# net.ipv4.tcp_mem = 94500000 915000000 927000000
# net.ipv4.tcp_fin_timeout = 1
# net.ipv4.tcp_keepalive_time = 30
# EOF

/sbin/sysctl -p

echo "### config ulimit"
echo "ulimit -SHn 100001" >> /etc/rc.local
echo "ulimit -SHn 100001" >> /etc/profile
echo "* soft nofile 100001" >> /etc/security/limits.conf
echo "* hard nofile 100002" >> /etc/security/limits.conf
echo "* soft nproc 100001" >> /etc/security/limits.conf
echo "* hard nproc 100002" >> /etc/security/limits.conf

ulimit -SHn 100001

echo "### config jenkins key"
mkdir -p /root/.ssh
cat >> /root/.ssh/authorized_keys << EOF

#Jenkins-New
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCy9VWnGKBIjn+aV7WeOGagNS9jasA1gGMPyQ4F6DmoP4FeGz9gESG/oHKkuKgMGdEpnu35SJXFzFcyWAY4N/cOPbmRJlkiYolBCeFtjFiXX8T8keaWWMvWj1b1pfITmm5zzBsb/MAJFTLcp6HMtM43WPU0/qh3+mHhMXfmzwGfVpYGaz5Kyjj7jHDkvuwmq9ta0tKBZWtuPkbZMuOOw0BA2jvX3dBtjCmfNVpm17V4pyhNz35qSEa6PxnIcu3jKaAfyBAv+I8DlaVYldorZLCKtBXBqCq2cH3VZxT9lrQl/n+vU82C9m/C+iMhEQFgLveLNjoJDUtHey0h4xc9Fw/D jenkins@jenkins
EOF

echo "### config end"