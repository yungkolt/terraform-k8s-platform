# Terraform Backend Configuration
# Uncomment and configure for production use

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "tfstateaksplatform"
#     container_name       = "tfstate"
#     key                  = "terraform.tfstate"
#   }
# }

# To set up the backend:
# 1. Create a storage account for Terraform state
# 2. Uncomment the backend configuration above
# 3. Run: terraform init -reconfigure

# Script to create the backend storage:
# az group create --name rg-terraform-state --location eastus
# az storage account create --resource-group rg-terraform-state --name tfstateaksplatform --sku Standard_LRS --encryption-services blob
# az storage container create --name tfstate --account-name tfstateaksplatform
