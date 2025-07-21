#!/bin/bash
set -e

echo "🔍 Comprehensive Kubernetes Platform Validation"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Check cluster connectivity
print_status "INFO" "Testing cluster connectivity..."
if kubectl cluster-info > /dev/null 2>&1; then
    print_status "SUCCESS" "Cluster is accessible"
    kubectl get nodes --no-headers | while read node status roles age version; do
        if [ "$status" = "Ready" ]; then
            print_status "SUCCESS" "Node $node is Ready"
        else
            print_status "ERROR" "Node $node is $status"
        fi
    done
else
    print_status "ERROR" "Cannot connect to cluster"
    exit 1
fi

# Check system pods
print_status "INFO" "Checking system pods..."
FAILED_PODS=$(kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers 2>/dev/null | wc -l)
if [ "$FAILED_PODS" -eq 0 ]; then
    print_status "SUCCESS" "All pods are running successfully"
else
    print_status "WARNING" "$FAILED_PODS pods are not in Running/Succeeded state"
    kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded
fi

# Check ingress controller
print_status "INFO" "Validating NGINX Ingress Controller..."
if kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --no-headers 2>/dev/null | grep -q Running; then
    print_status "SUCCESS" "NGINX Ingress Controller is running"
    
    # Check for LoadBalancer IP
    EXTERNAL_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -n "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
        print_status "SUCCESS" "LoadBalancer has external IP: $EXTERNAL_IP"
    else
        print_status "WARNING" "LoadBalancer IP not yet assigned"
    fi
else
    print_status "ERROR" "NGINX Ingress Controller not found"
fi

# Check monitoring stack
print_status "INFO" "Checking monitoring stack..."
if kubectl get namespace monitoring > /dev/null 2>&1; then
    # Check Prometheus
    if kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus --no-headers 2>/dev/null | grep -q Running; then
        print_status "SUCCESS" "Prometheus is running"
    else
        print_status "WARNING" "Prometheus not running or not found"
    fi
    
    # Check Grafana
    if kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana --no-headers 2>/dev/null | grep -q Running; then
        print_status "SUCCESS" "Grafana is running"
    else
        print_status "WARNING" "Grafana not running or not found"
    fi
else
    print_status "WARNING" "Monitoring namespace not found"
fi

# Check Flux GitOps
print_status "INFO" "Validating Flux GitOps..."
if command -v flux > /dev/null 2>&1; then
    if flux check > /dev/null 2>&1; then
        print_status "SUCCESS" "Flux CD is healthy"
        
        # Check Git repository sync
        if kubectl get gitrepository -n flux-system flux-system -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q True; then
            print_status "SUCCESS" "Git repository is synced"
        else
            print_status "WARNING" "Git repository sync issues detected"
        fi
    else
        print_status "WARNING" "Flux CD health check failed"
    fi
else
    print_status "INFO" "Flux CLI not installed - skipping GitOps validation"
fi

# Check auto-scaling
print_status "INFO" "Verifying auto-scaling configuration..."
HPA_COUNT=$(kubectl get hpa --all-namespaces --no-headers 2>/dev/null | wc -l)
if [ "$HPA_COUNT" -gt 0 ]; then
    print_status "SUCCESS" "Found $HPA_COUNT Horizontal Pod Autoscaler(s)"
    kubectl get hpa --all-namespaces --no-headers | while read namespace name reference targets minpods maxpods replicas age; do
        print_status "INFO" "HPA: $namespace/$name -> $targets (min:$minpods, max:$maxpods, current:$replicas)"
    done
else
    print_status "WARNING" "No Horizontal Pod Autoscalers found"
fi

# Check resource usage
print_status "INFO" "Checking resource utilization..."
kubectl top nodes --no-headers 2>/dev/null | while read node cpu_cores cpu_percent memory_bytes memory_percent; do
    cpu_num=$(echo $cpu_percent | sed 's/%//')
    mem_num=$(echo $memory_percent | sed 's/%//')
    
    if [ "$cpu_num" -lt 80 ] && [ "$mem_num" -lt 80 ]; then
        print_status "SUCCESS" "Node $node: CPU ${cpu_percent}, Memory ${memory_percent}"
    elif [ "$cpu_num" -ge 80 ] || [ "$mem_num" -ge 80 ]; then
        print_status "WARNING" "Node $node: High usage - CPU ${cpu_percent}, Memory ${memory_percent}"
    fi
done 2>/dev/null || print_status "INFO" "Metrics server not available for resource usage"

# Security validation
print_status "INFO" "Security validation..."
NETPOL_COUNT=$(kubectl get networkpolicies --all-namespaces --no-headers 2>/dev/null | wc -l)
if [ "$NETPOL_COUNT" -gt 0 ]; then
    print_status "SUCCESS" "Found $NETPOL_COUNT Network Policies"
else
    print_status "WARNING" "No Network Policies found - consider implementing zero-trust networking"
fi

# Check certificates
print_status "INFO" "Checking SSL certificates..."
if kubectl get clusterissuer --no-headers 2>/dev/null | grep -q letsencrypt; then
    print_status "SUCCESS" "Let's Encrypt ClusterIssuer found"
else
    print_status "WARNING" "No Let's Encrypt ClusterIssuer found"
fi

# Cost optimization check
print_status "INFO" "Cost optimization validation..."
SPOT_NODES=$(kubectl get nodes -l kubernetes.azure.com/scalesetpriority=spot --no-headers 2>/dev/null | wc -l)
if [ "$SPOT_NODES" -gt 0 ]; then
    print_status "SUCCESS" "Found $SPOT_NODES spot instance node(s) for cost optimization"
else
    print_status "INFO" "No spot instances detected"
fi

echo ""
print_status "INFO" "Validation complete! 🎉"
echo ""
print_status "INFO" "Quick access commands:"
echo "  📊 Grafana: kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "  🔍 Prometheus: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
echo "  🌐 Get LoadBalancer IP: kubectl get svc -n ingress-nginx"
echo "  📈 Check HPA: kubectl get hpa --all-namespaces"
echo "  🔄 Flux status: flux get all"
