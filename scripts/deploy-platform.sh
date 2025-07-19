#!/bin/bash
set -e

echo "🚀 Deploying Kubernetes Platform Components"

# Get AKS credentials
echo "📥 Getting AKS credentials..."
az aks get-credentials --resource-group rg-k8s-platform --name aks-platform --overwrite-existing

# Install NGINX Ingress
echo "🌐 Installing NGINX Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.enabled=true

# Install cert-manager
echo "🔒 Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Install Prometheus & Grafana
echo "📊 Installing Prometheus & Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --create-namespace --namespace monitoring \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# Install Sealed Secrets
echo "🔐 Installing Sealed Secrets..."
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Deploy sample application
echo "🚀 Deploying sample application..."
kubectl apply -f kubernetes/sample-app/

echo "✅ Platform deployment complete!"
echo ""
echo "📊 Access Grafana:"
echo "kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "Username: admin"
echo "Password: admin123"
