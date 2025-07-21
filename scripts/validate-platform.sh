#!/bin/bash
set -e

echo "🔍 Platform Validation"
echo "====================="

ISSUES=0

# Check cluster access
if kubectl cluster-info > /dev/null 2>&1; then
    echo "✅ Cluster accessible"
else
    echo "❌ Cannot access cluster"
    ((ISSUES++))
fi

# Check nodes
READY_NODES=$(kubectl get nodes --no-headers | grep " Ready " | wc -l)
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
echo "✅ Nodes: $READY_NODES/$TOTAL_NODES ready"

# Check critical pods
FAILED_PODS=$(kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers | wc -l)
if [ "$FAILED_PODS" -eq 0 ]; then
    echo "✅ All pods running"
else
    echo "⚠️  $FAILED_PODS pods not running"
    ((ISSUES++))
fi

# Check ingress
if kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' > /dev/null; then
    LB_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "✅ LoadBalancer IP: $LB_IP"
else
    echo "⚠️  LoadBalancer IP pending"
fi

# Check monitoring
if kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana --no-headers | grep -q Running; then
    echo "✅ Grafana running"
else
    echo "⚠️  Grafana not running"
    ((ISSUES++))
fi

# Check security policies
NETPOL_COUNT=$(kubectl get networkpolicies --all-namespaces --no-headers | wc -l)
echo "✅ Network policies: $NETPOL_COUNT"

# Check HPA
HPA_COUNT=$(kubectl get hpa --all-namespaces --no-headers | wc -l)
echo "✅ HPA configs: $HPA_COUNT"

echo ""
if [ $ISSUES -eq 0 ]; then
    echo "🎉 Platform validation successful!"
else
    echo "⚠️  Found $ISSUES issues"
fi
