#!/bin/bash

# This script deploys Grafana and additional components using Helm

set -e

echo "🚀 Starting application deployment..."

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

# Verify cluster is available
if ! kubectl cluster-info &> /dev/null; then
    print_message $RED "❌ No connection to Kubernetes cluster."
    print_message $YELLOW "Please run ./scripts/setup.sh first."
    exit 1
fi

# Verify namespaces exist
if ! kubectl get namespace monitoring &> /dev/null; then
    print_message $RED "❌ Namespace 'monitoring' does not exist."
    print_message $YELLOW "Please run ./scripts/setup.sh first."
    exit 1
fi

print_message $BLUE "📦 Checking Grafana status..."

# Check if Grafana is already running and healthy
if kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana --no-headers 2>/dev/null | grep -q "Running"; then
    print_message $GREEN "✅ Grafana is already running!"
    
    # Check if it's actually healthy
    if kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana --no-headers | grep -q "1/1.*Running"; then
        print_message $GREEN "🎉 Grafana is healthy and ready!"
        
        # Show current status
        print_message $BLUE "📊 Current Grafana status:"
        kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana
        kubectl get svc -n monitoring -l app.kubernetes.io/name=grafana
        
        # Skip deployment, just show access info
        print_message $BLUE "⏭️  Skipping deployment - Grafana is already running"
        
    else
        print_message $YELLOW "⚠️  Grafana exists but may have issues. Restarting..."
        kubectl rollout restart deployment/grafana -n monitoring
        print_message $GREEN "🔄 Grafana restarted"
    fi
    
else
    print_message $BLUE "📦 Deploying Grafana with Helm..."
    
    # Only install/upgrade if Grafana is not running
    helm upgrade --install grafana grafana/grafana \
        --namespace monitoring \
        --values helm/grafana/values.yaml \
        --wait \
        --timeout=10m
    
    print_message $GREEN "✅ Grafana deployed successfully!"
fi

# Verify deployment
print_message $BLUE "🔍 Verifying Grafana deployment..."

# Wait for pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s

# Show pod status
print_message $BLUE "📊 Pod status in monitoring namespace:"
kubectl get pods -n monitoring

# Show services
print_message $BLUE "🔗 Available services:"
kubectl get svc -n monitoring

# Show ingress (if enabled)
print_message $BLUE "🌐 Configured ingress:"
kubectl get ingress -n monitoring 2>/dev/null || echo "No ingress configured"

# Access information
print_message $GREEN "🎉 Deployment completed successfully!"
print_message $YELLOW "📝 Access information:"

echo ""
print_message $BLUE "🔑 Grafana credentials:"
echo "  Username: admin"
echo "  Password: admin123"

echo ""
print_message $BLUE "🌐 Access options:"
echo "  1. Port Forward (Recommended for local demo):"
echo "     kubectl port-forward svc/grafana 3000:80 -n monitoring"
echo "     Then access: http://localhost:3000"

echo ""
echo "  2. Ingress (If you have ingress controller):"
echo "     Access: http://grafana.local"
echo "     (Add '127.0.0.1 grafana.local' to your /etc/hosts)"

echo ""
echo "  3. Minikube (If using minikube):"
echo "     minikube service grafana -n monitoring"

echo ""
print_message $BLUE "📈 Useful commands to verify deployment:"
echo "  # View Grafana logs"
echo "  kubectl logs -l app.kubernetes.io/name=grafana -n monitoring"
echo ""
echo "  # Describe Grafana pod"
echo "  kubectl describe pod -l app.kubernetes.io/name=grafana -n monitoring"
echo ""
echo "  # View applied configuration"
echo "  helm get values grafana -n monitoring"

print_message $GREEN "✨ Ready for presentation!" 