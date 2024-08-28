provider "azurerm" {
  features = {}
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# output the resource group name
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
