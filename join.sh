#!/bin/bash

# Ensure the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Please run the script with sudo or as root."
    exit 1
fi

# Prompt the user to choose a node type
echo "Select node type:"
echo "  1) first-server (bootstrap)"
echo "  2) server (joining additional server node)"
echo "  3) agent (joining agent node)"
read -p "Enter the number corresponding to your node type: " NODE_CHOICE

case "$NODE_CHOICE" in
    1)
        NODE_TYPE="first-server"
        ;;
    2)
        NODE_TYPE="server"
        ;;
    3)
        NODE_TYPE="agent"
        ;;
    *)
        echo "Invalid selection. Please run the script again."
        exit 1
        ;;
esac

# For joining nodes (server or agent), prompt for additional details.
if [[ "$NODE_TYPE" == "server" || "$NODE_TYPE" == "agent" ]]; then
    read -p "Enter MASTER_SVR_IP: " MASTER_SVR_IP
    read -p "Enter MASTER_SVR_PORT: " MASTER_SVR_PORT
    read -p "Enter TOKEN: " TOKEN

    # Validate that all required values are provided
    if [[ -z "$MASTER_SVR_IP" || -z "$MASTER_SVR_PORT" || -z "$TOKEN" ]]; then
        echo "MASTER_SVR_IP, MASTER_SVR_PORT, and TOKEN are required for joining nodes."
        exit 1
    fi
fi

# Install necessary packages
apt-get update && apt-get install -y \
    curl wget git net-tools unzip apparmor-utils \
    ca-certificates cloud-init cloud-guest-utils cloud-image-utils \
    cloud-utils cloud-initramfs-growroot open-iscsi \
    openssh-server open-vm-tools nfs-common

# Perform a distribution upgrade
apt-get dist-upgrade -y

# If joining a cluster, create the RKE2 configuration file
if [[ "$NODE_TYPE" == "server" || "$NODE_TYPE" == "agent" ]]; then
    mkdir -p /etc/rancher/rke2/
    cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://${MASTER_SVR_IP}:${MASTER_SVR_PORT}
token: ${TOKEN}
EOF
fi

# Install and start the appropriate RKE2 role
case "$NODE_TYPE" in
    first-server)
        echo "Installing bootstrap RKE2 server..."
        curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh -
        systemctl enable --now rke2-server.service
        ;;
    server)
        echo "Installing joining RKE2 server..."
        curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server sh -
        systemctl enable --now rke2-server.service
        ;;
    agent)
        echo "Installing RKE2 agent..."
        curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=agent sh -
        systemctl enable --now rke2-agent.service
        ;;
esac
