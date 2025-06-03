# Kubernetes Automation Demo

This project demonstrates automated deployment of applications in Kubernetes using Helm, with emphasis on reproducibility and enterprise security.

## 🎯 What This Demo Shows

- ✅ **Automated Deployment**: Deploy Grafana monitoring dashboard with one command
- ✅ **Secret Management**: Secure credential handling outside application code  
- ✅ **Enterprise Authentication**: OAuth integration architecture with Keycloak
- ✅ **Multi-Cloud Ready**: Same configuration works on any Kubernetes cluster

## 📋 Prerequisites

### Required Software

**macOS (using Homebrew):**
```bash
# Install all requirements
brew install docker
brew install kubectl  
brew install helm
brew install minikube
```

**Windows (using Chocolatey):**
```powershell
# Install all requirements
choco install docker-desktop
choco install kubernetes-cli
choco install kubernetes-helm
choco install minikube
```

**Linux (Ubuntu/Debian):**
```bash
# Docker
sudo apt-get update && sudo apt-get install docker.io

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Verify Installation
```bash
docker version
kubectl version --client
helm version
minikube version
```

## 🚀 Quick Start

### 1. Start Docker
Make sure Docker Desktop is running on your machine.

### 2. Clone and Setup
```bash
# Download the project
git clone <repository-url>
cd kubernetes-automation-demo

# Give execution permissions to scripts
chmod +x scripts/*.sh

# Run initial setup (creates cluster, namespaces, secrets)
./scripts/setup.sh
```

### 3. Deploy Application
```bash
# Deploy Grafana monitoring dashboard
./scripts/deploy.sh
```

### 4. Access Application
```bash
# Forward Grafana to your local machine
kubectl port-forward svc/grafana 3000:80 -n monitoring

# Open browser: http://localhost:3000
# Username: admin
# Password: admin123
```

## 📊 What You'll See

After successful deployment:
- **Grafana Dashboard**: Professional monitoring interface
- **Kubernetes Pods**: Running containers in isolated namespaces
- **Secure Secrets**: Credentials managed separately from code
- **Enterprise Architecture**: Ready for OAuth authentication

## 🏗️ Architecture

```
┌─────────────────────┐    ┌─────────────────────┐
│   Grafana Pod       │    │   Kubernetes        │
│   (Monitoring UI)   │◄───┤   Secrets           │
│   Port: 3000        │    │   (Credentials)     │
└─────────────────────┘    └─────────────────────┘
           │
           ▼
┌─────────────────────┐
│   Your Browser      │
│   localhost:3000    │
└─────────────────────┘
```

## 🔧 Troubleshooting

### If deployment fails:
```bash
# Check pod status
kubectl get pods -n monitoring

# View logs
kubectl logs -l app.kubernetes.io/name=grafana -n monitoring

# Clean restart
helm uninstall grafana -n monitoring
./scripts/deploy.sh
```

### If port-forward disconnects:
```bash
# Kill any existing port-forwards
pkill -f "kubectl port-forward"

# Start fresh port-forward
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

## 🧹 Cleanup

To remove everything:
```bash
./scripts/cleanup.sh
```

## 💡 Enterprise Features

This demo includes enterprise-ready features:
- **Namespace isolation** for security
- **External secret management** for credential rotation
- **Helm charts** for reproducible deployments
- **OAuth architecture** for enterprise authentication
- **Multi-cloud compatibility** (AWS, Azure, GCP, on-premise)

---

**Ready in 5 minutes!** ⏱️
