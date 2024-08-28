# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.secret_id
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# Azure terraform backend
terraform {
  backend "azurerm" {
    resource_group_name  = "test-rg"
    storage_account_name = "storage22082024"
    container_name       = "tfstate"
    key                  = "multistorage.terraform.tfstate"
  }
}

#create azure resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}



# Create a storage account
resource "azurerm_storage_account" "storage" {
   name                 = "storageacct${count.index}"
  count                    = var.count_value
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

