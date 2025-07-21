#!/bin/bash
set -e

echo "🚀 Deploying Simplified AKS Platform"
echo "===================================="

# Check prerequisites
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl."
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Please install helm."
    exit 1
fi

# Get cluster credentials
echo "📥 Getting AKS credentials..."
az aks get-credentials --resource-group rg-k8s-platform --name aks-platform --overwrite-existing

# Deploy core components in order
echo "🔧 Deploying platform components..."

# 1. Security policies and RBAC
kubectl apply -f kubernetes/security/

# 2. Ingress controller
echo "🌐 Installing NGINX Ingress..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --set controller.metrics.enabled=true

# 3. Cert-manager
echo "🔒 Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
sleep 30
kubectl apply -f kubernetes/cert-manager/

# 4. Monitoring stack
echo "📊 Installing monitoring..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --create-namespace --namespace monitoring \
  -f kubernetes/monitoring/prometheus-values.yaml

# Apply monitoring rules
kubectl apply -f kubernetes/monitoring/monitoring-rules.yaml
kubectl apply -f kubernetes/monitoring/dashboards/

# 5. Deploy applications
echo "🚀 Deploying applications..."
kubectl apply -f kubernetes/apps/
kubectl apply -f kubernetes/ingress/

echo "✅ Platform deployment complete!"
echo ""
echo "📊 Access Grafana:"
echo "kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo ""
echo "🌐 Get LoadBalancer IP:"
echo "kubectl get svc -n ingress-nginx"
