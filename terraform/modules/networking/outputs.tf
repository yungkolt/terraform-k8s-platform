output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.aks.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.aks.id
}
