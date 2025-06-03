#!/bin/bash

# This script configures the initial environment for the Kubernetes demo

set -e

echo "🚀 Starting Kubernetes Automation Demo setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Verify prerequisites
print_message $BLUE "📋 Verifying prerequisites..."

# Verify kubectl
if ! command -v kubectl &> /dev/null; then
    print_message $RED "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Verify helm
if ! command -v helm &> /dev/null; then
    print_message $RED "❌ Helm is not installed. Please install Helm 3.x first."
    exit 1
fi

# Verify minikube or cluster connection
if ! kubectl cluster-info &> /dev/null; then
    print_message $YELLOW "⚠️  No connection to a Kubernetes cluster."
    print_message $BLUE "🔄 Attempting to start minikube..."
    
    if ! command -v minikube &> /dev/null; then
        print_message $RED "❌ minikube is not installed and no cluster connection available."
        print_message $YELLOW "Please install minikube or configure kubectl to connect to a cluster."
        exit 1
    fi
    
    # Start minikube with optimized configuration
    minikube start --driver=docker --memory=4096 --cpus=2
    
    # Enable necessary addons
    minikube addons enable ingress
    minikube addons enable metrics-server
    minikube addons enable storage-provisioner
    
    print_message $GREEN "✅ Minikube started successfully"
else
    print_message $GREEN "✅ Cluster connection established"
fi

# Show cluster information
print_message $BLUE "🔍 Cluster information:"
kubectl cluster-info
echo ""

# Add necessary Helm repositories
print_message $BLUE "📦 Adding Helm repositories..."

helm repo add grafana https://grafana.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

print_message $BLUE "🔄 Updating Helm repositories..."
helm repo update

# Create namespaces
print_message $BLUE "🏗️  Creating namespaces..."
kubectl apply -f k8s/namespaces/

# Wait for namespaces to be created
sleep 2

# Create secrets
print_message $BLUE "🔐 Creating secrets..."
kubectl apply -f k8s/secrets/

# Verify secrets were created correctly
print_message $BLUE "🔍 Verifying created secrets..."
kubectl get secrets -n monitoring
kubectl get secrets -n auth

print_message $GREEN "✅ Setup completed successfully!"
print_message $YELLOW "📝 Next steps:"
echo "  1. Run ./scripts/deploy.sh to deploy applications"
echo "  2. Use kubectl port-forward to access applications"
echo "  3. Review documentation in docs/ for more details"

print_message $BLUE "💡 To access Grafana after deployment:"
echo "  kubectl port-forward svc/grafana 3000:80 -n monitoring"
echo "  Username: admin"
echo "  Password: admin123" 