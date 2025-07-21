# AKS Platform Operations Guide

## Monitoring

### Access Grafana Dashboard

    kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

**Access Details:**
- URL: http://localhost:3000
- Username: admin
- Password: admin123

### View Container Insights

    az aks browse --resource-group rg-k8s-platform --name aks-platform

## Cost Management

### Check Current Costs

    az consumption usage list --start-date 2024-01-01 --end-date 2024-01-31

### View Budget Status

    az consumption budget list --resource-group rg-k8s-platform

## Scaling

### Manual Scaling

Scale node pool:

    az aks nodepool scale --resource-group rg-k8s-platform \
      --cluster-name aks-platform \
      --name spot \
      --node-count 5

Scale application:

    kubectl scale deployment sample-app --replicas=10

### Check Autoscaler Status

    kubectl describe cm cluster-autoscaler-status -n kube-system

## Troubleshooting

### Node Issues

    kubectl get nodes
    kubectl describe node <node-name>
    kubectl top nodes

### Pod Issues

    kubectl get pods --all-namespaces
    kubectl logs <pod-name> -n <namespace>
    kubectl describe pod <pod-name> -n <namespace>

### Storage Issues

    kubectl get pv
    kubectl get pvc --all-namespaces
    kubectl describe pvc <pvc-name> -n <namespace>

## Security

### View Network Policies

    kubectl get networkpolicies --all-namespaces
    kubectl describe networkpolicy <policy-name> -n <namespace>

### Check RBAC

    kubectl auth can-i --list
    kubectl get clusterrolebindings
    kubectl get rolebindings --all-namespaces

## Backup and Recovery

### Manual Backup

Backup all resources:

    kubectl get all --all-namespaces -o yaml > cluster-backup.yaml

Backup specific namespace:

    kubectl get all -n <namespace> -o yaml > namespace-backup.yaml

### Export Configurations

Export deployment configs:

    kubectl get deployments --all-namespaces -o yaml > deployments.yaml

Export services:

    kubectl get services --all-namespaces -o yaml > services.yaml

## Maintenance

### Cluster Upgrades

Check available versions:

    az aks get-upgrades --resource-group rg-k8s-platform --name aks-platform

Upgrade cluster:

    az aks upgrade --resource-group rg-k8s-platform \
      --name aks-platform \
      --kubernetes-version 1.28.3

### Node Maintenance

Cordon node (prevent new pods):

    kubectl cordon <node-name>

Drain node (move pods):

    kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

Uncordon node:

    kubectl uncordon <node-name>

## Quick Commands Reference

| Task | Command |
|------|---------|
| Get all pods | kubectl get pods -A |
| View logs | kubectl logs -f pod-name |
| Get events | kubectl get events --sort-by='.lastTimestamp' |
| View resources | kubectl top nodes |
| Get services | kubectl get svc -A |
| Describe ingress | kubectl describe ingress -A |

## Simplified Operations

### Quick Deployment
```bash
# Deploy entire platform
./scripts/deploy-platform.sh

# Validate deployment
./scripts/validate-platform.sh
```

### Security Operations
```bash
# Check network policies
kubectl get networkpolicies --all-namespaces

# Verify RBAC
kubectl auth can-i --list

# Check pod security
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.securityContext.runAsNonRoot}{"\n"}{end}'
```

### Monitoring Operations
```bash
# Access Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Check platform health
kubectl get pods --all-namespaces | grep -v Running
```
