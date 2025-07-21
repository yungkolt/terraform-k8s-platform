#!/bin/bash
set -e

echo "💰 AKS Platform Cost Monitoring Dashboard"
echo "========================================"

# Get current resource usage
echo "📊 Current Resource Usage:"
echo "------------------------"

# Node information
echo "🖥️  Node Information:"
kubectl get nodes -o custom-columns="NAME:.metadata.name,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,ZONE:.metadata.labels.topology\.kubernetes\.io/zone,PRIORITY:.metadata.labels.kubernetes\.azure\.com/scalesetpriority"

echo ""
echo "📈 Resource Consumption:"

# CPU and Memory usage per node
kubectl top nodes 2>/dev/null || echo "⚠️  Metrics server not available"

echo ""
echo "💾 Storage Usage:"
kubectl get pv -o custom-columns="NAME:.metadata.name,CAPACITY:.spec.capacity.storage,CLASS:.spec.storageClassName,STATUS:.status.phase"

echo ""
echo "🔢 Pod Count by Namespace:"
kubectl get pods --all-namespaces --no-headers | awk '{print $1}' | sort | uniq -c | sort -nr

echo ""
echo "💡 Cost Optimization Opportunities:"
echo "-----------------------------------"

# Check for pods without resource limits
echo "🚨 Pods without resource limits (potential cost risk):"
kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.spec.containers[].resources.limits == null) | "\(.metadata.namespace)/\(.metadata.name)"' 2>/dev/null | head -10 || echo "jq not available - install for detailed analysis"

# Spot node utilization
SPOT_NODES=$(kubectl get nodes -l kubernetes.azure.com/scalesetpriority=spot --no-headers | wc -l)
REGULAR_NODES=$(kubectl get nodes -l kubernetes.azure.com/scalesetpriority!=spot --no-headers | wc -l)

echo ""
echo "💰 Cost Summary:"
echo "System nodes: $REGULAR_NODES (estimated ~\$150/month)"
echo "Spot nodes: $SPOT_NODES (estimated ~\$60/month, 70% savings)"
echo "Total estimated: ~\$$(( (REGULAR_NODES * 75) + (SPOT_NODES * 30) ))/month"

echo ""
echo "📋 Recommendations:"
echo "• Monitor spot node usage and adjust workload placement"
echo "• Set resource limits on all pods to prevent resource waste"
echo "• Use HPA to automatically scale based on demand"
echo "• Review and cleanup unused PVs and services"
