variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-k8s-platform"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-platform"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.3"
}

variable "node_pools" {
  description = "Node pool configuration"
  type = map(object({
    vm_size         = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    priority        = string
    spot_max_price  = number
  }))
  default = {
    system = {
      vm_size         = "Standard_D2s_v3"
      node_count      = 2
      min_count       = 2
      max_count       = 4
      os_disk_size_gb = 100
      priority        = "Regular"
      spot_max_price  = -1
    }
    spot = {
      vm_size         = "Standard_D4s_v3"
      node_count      = 1
      min_count       = 0
      max_count       = 10
      os_disk_size_gb = 100
      priority        = "Spot"
      spot_max_price  = 0.5
    }
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "K8s-Platform"
    ManagedBy   = "Terraform"
  }
}
