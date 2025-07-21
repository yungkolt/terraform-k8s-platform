# 🚀 Kubernetes Platform Deployment Checklist

## Pre-Deployment ✅

- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] Terraform >= 1.5.0 installed
- [ ] kubectl installed
- [ ] Helm 3+ installed
- [ ] Subscription has sufficient quotas for AKS

## Infrastructure Deployment ✅

- [ ] `cd terraform && terraform init`
- [ ] `terraform plan` (review resources)
- [ ] `terraform apply` (deploy infrastructure)
- [ ] Verify cluster: `kubectl get nodes`

## Platform Components ✅

- [ ] Deploy platform: `./scripts/deploy-platform.sh`
- [ ] Install GitOps: `./scripts/install-flux.sh`
- [ ] Install service mesh: `./scripts/install-linkerd.sh` (optional)
- [ ] Install backup: `./scripts/install-velero.sh`

## Validation ✅

- [ ] Run validation: `./scripts/validate-platform.sh`
- [ ] Check monitoring: Access Grafana dashboard
- [ ] Verify ingress: Check LoadBalancer IP assignment
- [ ] Test auto-scaling: Deploy sample app and generate load
- [ ] Validate security: Check network policies and RBAC

## Post-Deployment ✅

- [ ] Configure DNS for your domain (if using custom domain)
- [ ] Set up backup schedules
- [ ] Configure alerting rules
- [ ] Document access procedures for team
- [ ] Set up cost monitoring and budgets

## Production Readiness ✅

- [ ] Security scan passed
- [ ] Backup/restore tested
- [ ] Monitoring alerts configured
- [ ] Documentation updated
- [ ] Team access configured
- [ ] Disaster recovery plan documented

## Troubleshooting Commands

```bash
# Check cluster health
kubectl get nodes
kubectl get pods --all-namespaces

# Debug pod issues
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>

# Check ingress
kubectl get svc -n ingress-nginx

# Monitor resources
kubectl top nodes
kubectl top pods --all-namespaces

# Flux status
flux get all
flux logs --follow

# Manual backup
velero backup create manual-$(date +%Y%m%d)
```
