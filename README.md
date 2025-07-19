# Kubernetes Cloud-Native Application Platform

A production-ready Kubernetes platform on Azure AKS with automated deployments, monitoring, and GitOps.

## 🏗️ Architecture

- **Infrastructure**: Azure Kubernetes Service (AKS) deployed with Terraform
- **Networking**: Ingress with NGINX and automatic SSL via cert-manager
- **Monitoring**: Prometheus & Grafana stack with custom dashboards
- **GitOps**: FluxCD for continuous deployment
- **Applications**: Sample microservices with auto-scaling

## 🚀 Features

- ✅ One-command cluster deployment
- ✅ Automatic SSL certificates
- ✅ Horizontal Pod Autoscaling (HPA)
- ✅ Prometheus monitoring with Grafana dashboards
- ✅ GitOps-based deployments
- ✅ Cost optimization with spot instances
- ✅ Network policies for security
- ✅ Automated backups with Velero

## 📋 Prerequisites

- Azure CLI
- Terraform >= 1.5.0
- kubectl
- Helm 3
- Docker (for local testing)

## 🚀 Quick Start

1. Clone the repository
2. Configure Azure credentials
3. Deploy the infrastructure:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

4. Deploy the platform components:
   ```bash
   ./scripts/deploy-platform.sh
   ```

## 📊 Monitoring

Access Grafana dashboard:
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```

Default credentials: admin/admin

## 🔒 Security

- NetworkPolicies enforced
- Pod Security Standards enabled
- RBAC configured
- Secrets management with Sealed Secrets

## 💰 Cost Optimization

- Spot instances for non-critical workloads
- Cluster autoscaling
- Resource limits enforced
- Scheduled scaling for dev environments
