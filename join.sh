#!/bin/bash

# Check if running with privileged user
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please run the script with sudo or root."
    exit
fi

MASTER_SVR_IP="$IP"
MASTER_SVR_PORT="$P"
TOKEN="$T"
NODE_TYPE="$TYPE"

# Get the necessary packages and updates
sudo apt-get update && sudo apt-get install -y curl wget git net-tools unzip apparmor-utils ca-certificates cloud-init cloud-guest-utils cloud-image-utils cloud-utils cloud-initramfs-growroot open-iscsi openssh-server open-vm-tools nfs-common

# Distro upgrade
sudo apt dist-upgrade -y

# Create config to join cluster
mkdir -p /etc/rancher/rke2/ 
echo "server: https://${MASTER_SVR_IP}:${MASTER_SVR_PORT}" > /etc/rancher/rke2/config.yaml
echo "token: ${TOKEN}" >> /etc/rancher/rke2/config.yaml

# If create RKE2 server node (controlplane + etcd)
if [ "$NODE_TYPE" = "server" ]; then
    curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh - 
    systemctl enable --now rke2-server.service

# Else if agent node
elif [ "$NODE_TYPE" = "agent" ]; then
    curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=agent sh -
    systemctl enable --now rke2-agent.service
fi
