#!/bin/bash
set -e

echo "🔐 Installing Velero for backup and disaster recovery..."

# Variables
AZURE_BACKUP_RESOURCE_GROUP="MC_rg-k8s-platform_aks-platform_eastus"
AZURE_STORAGE_ACCOUNT="aksplatformbackups$RANDOM"

# Create storage account for backups
echo "📦 Creating Azure storage account for backups..."
az storage account create \
    --name $AZURE_STORAGE_ACCOUNT \
    --resource-group $AZURE_BACKUP_RESOURCE_GROUP \
    --sku Standard_LRS \
    --encryption-services blob \
    --https-only true \
    --kind BlobStorage \
    --access-tier Hot

# Create blob container
echo "🗄️ Creating blob container..."
az storage container create \
    --name velero-backups \
    --account-name $AZURE_STORAGE_ACCOUNT \
    --public-access off

# Install Velero
echo "📥 Installing Velero..."
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

# Create namespace
kubectl create namespace velero --dry-run=client -o yaml | kubectl apply -f -

# Install with Helm
helm upgrade --install velero vmware-tanzu/velero \
    --namespace velero \
    --create-namespace \
    -f kubernetes/backup/velero-values.yaml \
    --wait

# Apply backup schedules
echo "⏰ Creating backup schedules..."
kubectl apply -f kubernetes/backup/backup-schedules.yaml

echo "✅ Velero installed successfully!"
echo ""
echo "View backups: velero backup get"
echo "Create manual backup: velero backup create manual-backup"
