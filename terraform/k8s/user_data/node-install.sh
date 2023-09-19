#!/bin/bash

# set hostname
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

case $PRIVATE_IP in
  "172.31.36.101")
    HOSTNAME="k8smaster"
    ;;
  "172.31.36.102")
    HOSTNAME="k8sworker1"
    ;;
  "172.31.36.103")
    HOSTNAME="k8sworker2"
    ;;
  "172.31.36.104")
    HOSTNAME="k8sworker3"
    ;;
esac

sudo hostnamectl set-hostname $HOSTNAME

# set hostfile
cat <<EOF | sudo tee -a /etc/hosts

172.31.36.101 k8smaster
172.31.36.102 k8sworker1
172.31.36.103 k8sworker2
172.31.36.104 k8sworker3
EOF

# swap off
sudo swapoff -a

# EBS mount
sudo mkfs.ext4 /dev/nvme1n1
sudo mkdir /data -p
echo '/dev/nvme1n1 /data ext4 defaults 0 0' | sudo tee -a /etc/fstab > /dev/null
sudo mount -a

# network plugin setting
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params setting
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# docker install
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin -y

sudo mkdir /data/docker_dir -p
sudo tee -a /etc/docker/daemon.json > /dev/null << EOT
{ 
   "data-root": "/data/docker_dir" 
}
EOT

sudo systemctl enable docker --now
sudo systemctl restart docker

# cri-dockerd install
curl -L https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest -H "Accept: application/vnd.github+json" | jq ".assets[-1].browser_download_url" | xargs wget
find . -name *.deb | xargs sudo dpkg -i
find . -name *.deb | xargs rm

# k8s install
sudo apt-get install -y apt-transport-https ca-certificates curl
#sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
