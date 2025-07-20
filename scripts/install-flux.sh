#!/bin/bash
set -e

echo "🚀 Installing Flux CD for GitOps..."

# Check prerequisites
echo "📋 Checking prerequisites..."
kubectl version --client
git --version

# Install Flux CLI if not present
if ! command -v flux &> /dev/null; then
    echo "📥 Installing Flux CLI..."
    curl -s https://fluxcd.io/install.sh | sudo bash
fi

# Create flux-system namespace
echo "📦 Creating flux-system namespace..."
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -

# Install Flux components
echo "🔧 Installing Flux components..."
flux install --namespace=flux-system

# Apply our Flux configuration
echo "🔄 Applying Flux sync configuration..."
kubectl apply -f kubernetes/flux/flux-sync.yaml

# Wait for Flux to be ready
echo "⏳ Waiting for Flux to be ready..."
kubectl -n flux-system wait --for=condition=ready pod -l app.kubernetes.io/part-of=flux --timeout=300s

# Check Flux status
echo "✅ Checking Flux status..."
flux check

echo "✅ Flux CD installed successfully!"
echo ""
echo "Monitor sync status with: flux get all"
echo "View logs with: flux logs --follow"
