# Application Host // Docker

resource "azurerm_storage_account" "appvm_storageaccount" {
  name                     = "app${var.projectPrefix}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = var.tags
}

# network interface for app vm
resource "azurerm_network_interface" "app01-nic" {
  name                = "${var.projectPrefix}-app01-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.appSubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.app01ip
    primary                       = true
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "app-nsg" {
  network_interface_id      = azurerm_network_interface.app01-nic.id
  network_security_group_id = var.security_group.id
}

data "template_file" "ocserv_socket" {
  template = templatefile("${path.module}/../templates/ocserv.socket", {

  })
}

data "template_file" "ocserv_conf" {
  template = templatefile("${path.module}/../templates/ocserv.conf", {

  })
}


# app01-VM
resource "azurerm_virtual_machine" "app01-vm" {
  name                = "${var.projectPrefix}-app01-vm"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  network_interface_ids = [azurerm_network_interface.app01-nic.id]
  vm_size               = var.instanceType

  storage_os_disk {
    name              = "${var.projectPrefix}-appOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.appvm_storageaccount.primary_blob_endpoint
  }

  os_profile {
    computer_name  = "app01"
    admin_username = var.adminUserName
    admin_password = var.adminPassword
    custom_data    = <<-EOF
#!/bin/bash
apt-get update -y;

EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}
