#!/bin/bash
set -e

echo "🕸️  Installing Linkerd service mesh..."

# Install Linkerd CLI
if ! command -v linkerd &> /dev/null; then
    echo "📥 Installing Linkerd CLI..."
    curl -sL https://run.linkerd.io/install | sh
    export PATH=$PATH:$HOME/.linkerd2/bin
fi

# Check prerequisites
linkerd check --pre

# Generate certificates for mTLS
echo "🔐 Generating mTLS certificates..."
step certificate create root.linkerd.cluster.local ca.crt ca.key \
  --profile root-ca --no-password --insecure || {
    echo "Using Linkerd auto-generated certificates"
}

# Install Linkerd control plane
echo "🎮 Installing Linkerd control plane..."
linkerd install \
  --ha \
  --proxy-cpu-request="10m" \
  --proxy-memory-request="20Mi" \
  | kubectl apply -f -

# Wait for control plane
linkerd check

# Install viz extension
echo "📊 Installing Linkerd viz extension..."
linkerd viz install | kubectl apply -f -

# Install jaeger extension for tracing
echo "🔍 Installing Linkerd jaeger extension..."
linkerd jaeger install | kubectl apply -f -

# Apply our custom configurations
kubectl apply -f kubernetes/service-mesh/

echo "✅ Linkerd installation complete!"
echo "🌐 Access dashboard: linkerd viz dashboard"
