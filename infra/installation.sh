#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export SYSTEMD_COLORS=0
export SYSTEMD_PAGER=

alias systemctl='systemctl --no-pager'
alias journalctl='journalctl --no-pager'

# Ensure automatic restart of services
sudo sed -i 's/^#\$nrconf{restart} = .*/$nrconf{restart} = '\''a'\'';/; s/^\$nrconf{restart} = .*/$nrconf{restart} = '\''a'\'';/' /etc/needrestart/needrestart.conf

# Create directories
mkdir -p ~/.local/bin

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install basic tools
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Install Docker (required for kind)
echo "Installing Docker..."
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Enable IP forwarding
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Disable swap (Kubernetes requirement)
sudo swapoff -a

# Install kubectl
echo "Installing kubectl..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | \
  gpg --dearmor | \
  sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl
sudo apt-mark hold kubectl

# Install Helm
echo "Installing Helm..."
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

# Install Kind
echo "Installing Kind..."
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
elif [ "$ARCH" = "aarch64" ]; then
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-arm64
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create Kind cluster config with ingress ports
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
      - containerPort: 443
        hostPort: 443
EOF

# Create Kind cluster
kind create cluster --config kind-config.yaml

# Install Ingress Controller for Kind
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller
kubectl rollout status deployment ingress-nginx-controller -n ingress-nginx --timeout=180s || true

# Install the QR Code application via Helm
helm install qrcode ./QRCode_APP_Chart   \
  --set-string Secret.DB_PASSWORD="$DB_PASSWORD"   \
  --set-string Secret.DB_HOST="$DB_HOST"   \
  --set-string Secret.DB_NAME="$DB_NAME"   \
  --set-string Secret.DB_USER="$DB_USER"
