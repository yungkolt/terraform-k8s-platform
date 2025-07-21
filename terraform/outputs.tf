# AKS Cluster Outputs
output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = module.aks.cluster_id
}

output "kube_config" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools"
  value       = module.aks.kube_config_raw
  sensitive   = true
}

output "cluster_endpoint" {
  description = "The Kubernetes cluster server endpoint"
  value       = module.aks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = module.aks.cluster_ca_certificate
  sensitive   = true
}

# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Node Pool Information
output "system_node_pool_info" {
  description = "Information about the system node pool"
  value = {
    name     = "system"
    vm_size  = var.node_pools["system"].vm_size
    min_count = var.node_pools["system"].min_count
    max_count = var.node_pools["system"].max_count
  }
}

output "spot_node_pool_info" {
  description = "Information about the spot node pool"
  value = {
    name          = "spot"
    vm_size       = var.node_pools["spot"].vm_size
    min_count     = var.node_pools["spot"].min_count
    max_count     = var.node_pools["spot"].max_count
    spot_max_price = var.node_pools["spot"].spot_max_price
  }
}

# Monitoring Outputs
output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = module.aks.log_analytics_workspace_id
}

# Connection Information
output "get_credentials_command" {
  description = "Command to get AKS credentials"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name}"
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    system_nodes = "~$150 (2-4 Standard_D2s_v3 nodes)"
    spot_nodes   = "~$60 (0-10 Standard_D4s_v3 spot nodes, 70% savings)"
    storage      = "~$50 (Premium SSD)"
    load_balancer = "~$25 (Standard Load Balancer)"
    monitoring   = "~$100 (Log Analytics)"
    total        = "~$385/month"
  }
}
