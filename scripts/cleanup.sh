#!/bin/bash

# This script cleans up all deployed resources

set -e

echo "🧹 Starting resource cleanup..."

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

# Confirm before proceeding
print_message $YELLOW "⚠️  This operation will delete all demo resources."
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_message $BLUE "Operation cancelled."
    exit 0
fi

# Remove Grafana using Helm
print_message $BLUE "🗑️  Removing Grafana..."
if helm list -n monitoring | grep -q grafana; then
    helm uninstall grafana -n monitoring
    print_message $GREEN "✅ Grafana removed"
else
    print_message $YELLOW "⚠️  Grafana not found in Helm"
fi

# Remove secrets
print_message $BLUE "🔐 Removing secrets..."
kubectl delete -f k8s/secrets/ --ignore-not-found=true

# Remove namespaces (this will delete all resources within)
print_message $BLUE "🏗️  Removing namespaces..."
kubectl delete -f k8s/namespaces/ --ignore-not-found=true

# Wait for resources to be deleted completely
print_message $BLUE "⏳ Waiting for resources to be deleted completely..."
sleep 10

# Verify everything has been removed
print_message $BLUE "🔍 Verifying cleanup..."

# Verify namespaces
if kubectl get namespace monitoring &> /dev/null; then
    print_message $YELLOW "⚠️  Namespace 'monitoring' still exists (may take time to delete)"
else
    print_message $GREEN "✅ Namespace 'monitoring' deleted"
fi

if kubectl get namespace auth &> /dev/null; then
    print_message $YELLOW "⚠️  Namespace 'auth' still exists (may take time to delete)"
else
    print_message $GREEN "✅ Namespace 'auth' deleted"
fi

# Verify Helm releases
if helm list -A | grep -q grafana; then
    print_message $YELLOW "⚠️  Grafana releases still exist in Helm"
else
    print_message $GREEN "✅ No Grafana releases in Helm"
fi

print_message $GREEN "🎉 Cleanup completed!"
print_message $BLUE "💡 Notes:"
echo "  - PersistentVolumes may require manual deletion"
echo "  - Namespaces may take a few minutes to delete completely"
echo "  - If using minikube, you can delete it completely with: minikube delete"

print_message $YELLOW "🔄 To redeploy:"
echo "  1. ./scripts/setup.sh"
echo "  2. ./scripts/deploy.sh" 