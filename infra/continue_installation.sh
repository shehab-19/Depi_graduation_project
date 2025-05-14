#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# ======================================= Kubectl Installation ==================================================
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
sudo apt-get update
sudo apt-get install -y kubectl

# ======================================= Kind Installation ==================================================
# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# ======================================= Kind Cluster Setup ==================================================
cat <<EOF | kind create cluster --config=-
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
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
- role: worker
- role: worker
- role: worker
EOF

kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
sleep 5

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=250s

# ======================================= Helm Installtion ==================================================
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

# ======================================= Install the QR Code application via Helm ==================================================
helm install qrcode ./QRCode_APP_Chart   \
  --set-string Secret.DB_PASSWORD="$DB_PASSWORD"   \
  --set-string Secret.DB_HOST="$DB_HOST"   \
  --set-string Secret.DB_NAME="$DB_NAME"   \
  --set-string Secret.DB_USER="$DB_USER"   \
  --set-string Ingress.HostName="$URL" 

# ====================== Install Argo CD ======================
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.0.0/manifests/install.yaml

sleep 5
# Wait for Argo CD to be ready
echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=250s deployment/argocd-server -n argocd

# ====================== Install Argo CD CLI ======================
wget https://github.com/argoproj/argo-cd/releases/download/v3.0.0/argocd-linux-amd64
chmod +x argocd-linux-amd64
sudo mv argocd-linux-amd64 /usr/local/bin/argocd

echo "===== Exposing Argo CD API server via NodePort ====="
kubectl patch svc argocd-server -n argocd --type='merge' -p '{
  "spec": {
    "type": "NodePort",
    "ports": [
      {
        "port": 443,
        "targetPort": 8080,
        "nodePort": 30080,
        "protocol": "TCP",
        "name": "https"
      }
    ]
  }
}'
# ====================== Login in Argo CD  ======================

ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)
argocd login "$(curl -s http://checkip.amazonaws.com):30080" \
  --username admin \
  --password "$ARGOCD_PWD" \
  --insecure \
  --grpc-web
echo "ArgoCD admin password: $ARGOCD_PWD"
kubectl apply -f /home/ubuntu/argocd.yaml


