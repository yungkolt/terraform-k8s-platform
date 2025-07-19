terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# AKS Cluster
module "aks" {
  source = "./modules/aks"

  cluster_name        = var.cluster_name
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  kubernetes_version = var.kubernetes_version
  
  node_pools = var.node_pools
  
  tags = var.tags
}

# Networking Components
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  cluster_name       = module.aks.cluster_name
  
  depends_on = [module.aks]
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = module.aks.kube_config.0.host
  client_certificate     = base64decode(module.aks.kube_config.0.client_certificate)
  client_key             = base64decode(module.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kube_config.0.host
    client_certificate     = base64decode(module.aks.kube_config.0.client_certificate)
    client_key             = base64decode(module.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config.0.cluster_ca_certificate)
  }
}
