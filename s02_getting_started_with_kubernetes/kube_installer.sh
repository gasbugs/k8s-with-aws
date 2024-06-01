#!/bin/bash
# 스왑 비활성화
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# 쿠버네티스 관련 레파지토리 추가
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# containerd 설치
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum install -y containerd

# 쿠버네티스를 위한 Containerd 설정
cat <<EOF | sudo tee -a /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true
EOF

sudo sed -i 's/^disabled_plugins \=/\#disabled_plugins \=/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# 필요한 패키지 설치
sudo yum update -y
sudo yum list -y kubeadm-1.27.0 kubectl-1.27.0
sudo yum install -y kubelet-1.27.1-0 kubeadm-1.27.1-0 kubectl-1.27.1-0 --disableexcludes=kubernetes

# 리눅스 넷필터 설정
sudo modprobe br_netfilter
echo 1 > 1.txt
sudo cp 1.txt /proc/sys/net/ipv4/ip_forward
sudo cp 1.txt /proc/sys/net/bridge/bridge-nf-call-iptables
rm 1.txt

# 도커와 kubelet 서비스 시작하기
sudo systemctl enable containerd && sudo systemctl start containerd
sudo systemctl enable kubelet && sudo systemctl start kubelet

# 방화벽 해제
#sudo systemctl stop firewalld
#sudo systemctl disable firewalld