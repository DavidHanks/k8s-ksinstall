#!/bin/bash

echo "update os"
sudo apt update >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common >/dev/null 2>&1

# setup timezone
echo "[TASK 0] Set timezone"
timedatectl set-timezone Asia/Shanghai
apt-get update >/dev/null 2>&1
apt-get install -y ntpdate >/dev/null 2>&1
ntpdate ntp.aliyun.com

echo "[TASK 1] install some tools"
apt install -qq -y vim jq iputils-ping net-tools >/dev/null 2>&1

echo "[TASK 2] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 3] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 4] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK 5] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

echo "[TASK 6] Install containerd runtime"
apt-get update >/dev/null 2>&1
apt-get install -y containerd >/dev/null 2>&1
mkdir -p /etc/containerd
containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sed -i 's/registry.k8s.io\/pause:3.8/registry.aliyuncs.com\/google_containers\/pause:3.10/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1


echo "[TASK 7] Add apt repo for kubernetes"
curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.33/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.33/deb/ /" |
    sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update >/dev/null 2>&1
apt-get install -y kubelet kubeadm kubectl >/dev/null 2>&1
apt-mark hold kubelet kubeadm kubectl >/dev/null 2>&1

echo "[TASK 8] Print something"
containerd --version
kubelet --version
