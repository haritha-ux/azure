provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}
#Create Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
#Create stroage account
resource "azurerm_storage_account" "storage" {

  name                     = lower(var.storage_account_name)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags

}

#create Virtual Network 
resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_network_security_group.nsg]
  name                = "var.virtual_network_name"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["192.168.0.0/24"]

}
#create subnet

resource "azurerm_subnet" "subnet" {
  depends_on           = [azurerm_virtual_network.vnet, azurerm_network_security_group.nsg]
  name                 = "var.subnet_name"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.0.0/24"]

}

#create public ip

resource "azurerm_public_ip" "publicip" {
  name                = "var.publicip_name"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

#create network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "var.nsg_name"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#Associate nsg with subnet
resource "azurerm_subnet_network_security_group_association" "name" {

  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#create a NIC
resource "azurerm_network_interface" "nic" {
  depends_on          = [azurerm_public_ip.publicip, azurerm_virtual_network.vnet, azurerm_subnet.subnet]
  name                = "var.nic_name"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

#create virtual machine
resource "azurerm_windows_virtual_machine" "vm" {

  depends_on          = [azurerm_network_interface.nic]
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  #zone = 3
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}



