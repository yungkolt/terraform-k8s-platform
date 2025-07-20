resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    node_count          = var.node_pools["system"].node_count
    vm_size             = var.node_pools["system"].vm_size
    os_disk_size_gb     = var.node_pools["system"].os_disk_size_gb
    enable_auto_scaling = true
    min_count          = var.node_pools["system"].min_count
    max_count          = var.node_pools["system"].max_count
    
    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  auto_scaler_profile {
    scale_down_delay_after_add = "10m"
    scale_down_unneeded        = "10m"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  tags = var.tags
}

# Spot Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size              = var.node_pools["spot"].vm_size
  node_count           = var.node_pools["spot"].node_count
  
  enable_auto_scaling = true
  min_count          = var.node_pools["spot"].min_count
  max_count          = var.node_pools["spot"].max_count
  
  priority        = "Spot"
  spot_max_price  = var.node_pools["spot"].spot_max_price
  eviction_policy = "Delete"
  
  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }
  
  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  tags = var.tags
}
