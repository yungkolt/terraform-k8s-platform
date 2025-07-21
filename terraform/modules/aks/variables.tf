variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use for the cluster"
  type        = string
  default     = "1.28.3"
}

variable "node_pools" {
  description = "Configuration for node pools"
  type = map(object({
    vm_size         = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    priority        = string
    spot_max_price  = number
  }))
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
  default     = ""
}

variable "budget_alert_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = ["alerts@example.com"]
}

variable "network_plugin" {
  description = "Network plugin to use for networking"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy to use"
  type        = string
  default     = "calico"
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
  default     = ""
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the default node pool"
  type        = bool
  default     = true
}

variable "enable_node_public_ip" {
  description = "Enable public IP for nodes"
  type        = bool
  default     = false
}

variable "load_balancer_sku" {
  description = "Load balancer SKU"
  type        = string
  default     = "standard"
}

variable "outbound_type" {
  description = "Outbound routing method"
  type        = string
  default     = "loadBalancer"
}
