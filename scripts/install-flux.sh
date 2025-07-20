#!/bin/bash
set -e

echo "🚀 Installing Flux CD for GitOps..."

# Check if flux CLI is installed
if ! command -v flux &> /dev/null; then
    echo "📥 Installing Flux CLI..."
    curl -s https://fluxcd.io/install.sh | sudo bash
fi

# Pre-check
echo "🔍 Running pre-installation checks..."
flux check --pre

# Create namespace
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -

# Install Flux components
echo "🔧 Installing Flux components..."
flux install \
  --namespace=flux-system \
  --network-policy=false \
  --components-extra=image-reflector-controller,image-automation-controller

# Apply our configurations
echo "📦 Applying Flux configurations..."
kubectl apply -f kubernetes/flux-system/namespace.yaml
kubectl apply -f kubernetes/flux-system/gotk-sync.yaml
kubectl apply -f kubernetes/clusters/production/

# Wait for Flux
echo "⏳ Waiting for Flux to be ready..."
kubectl -n flux-system wait --for=condition=ready pod -l app.kubernetes.io/part-of=flux --timeout=300s

# Check status
flux check

echo "✅ Flux CD installed successfully!"
echo "📊 Monitor with: flux get all"
echo "📝 View logs with: flux logs --follow"
