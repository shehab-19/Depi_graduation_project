#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export SYSTEMD_COLORS=0
export SYSTEMD_PAGER=
alias systemctl='systemctl --no-pager'
alias journalctl='journalctl --no-pager'

sudo sed -i 's/^#\$nrconf{restart} = .*/$nrconf{restart} = '\''a'\'';/; s/^\$nrconf{restart} = .*/$nrconf{restart} = '\''a'\'';/' /etc/needrestart/needrestart.conf

# Create directories
mkdir -p ~/.local/bin

# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

sleep 2

sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sleep 2

# Install containerd
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl start containerd

sleep 2

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo swapoff -a

###  Install kind and create cluster with port mappings
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

## Creating kind cluster with ports 80 and 443 exposed..."
kind create cluster --config=- <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
EOF

# Wait for Kubernetes API to be ready
echo "Waiting for Kubernetes API server to respond to kubectl..."
for i in {1..20}; do
  if kubectl version --short &>/dev/null; then
    echo "Kubernetes API server is ready."
    break
  else
    echo "Waiting for API server... ($i/20)"
    sleep 5
  fi
done

# Install Helm
echo "Installing Helm..."
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

# Install ingress-nginx for kind
echo "[+] Installing ingress-nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo "[+] Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# Install the QR Code application via Helm
helm install qrcode ./QRCode_APP_Chart \
  --set-string Secret.DB_PASSWORD="$DB_PASSWORD" \
  --set-string Secret.DB_HOST="$DB_HOST" \
  --set-string Secret.DB_NAME="$DB_NAME" \
  --set-string Secret.DB_USER="$DB_USER"
