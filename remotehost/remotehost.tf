# Application Host // Docker

resource "azurerm_storage_account" "rhvm_storageaccount" {
  name                     = "rh${var.projectPrefix}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = var.tags
}

# network interface for app vm
resource "azurerm_network_interface" "rh01-nic" {
  name                = "${var.projectPrefix}-rh01-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.rhSubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.rh01ip
    public_ip_address_id          = var.publicip_id
    primary                       = true
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "rh-nsg" {
  network_interface_id      = azurerm_network_interface.rh01-nic.id
  network_security_group_id = var.security_group.id
}

data "template_file" "init" {
  template = file("${path.module}/../templates/cloud-init.yaml")

  vars = {
    owner    = var.tags["owner"]
    fqdn     = var.publicip
    password = var.adminPassword
  }
}

data "template_file" "ocserv_socket" {
  template = templatefile("${path.module}/../templates/ocserv.socket", {

  })
}

data "template_file" "ocserv_conf" {
  template = templatefile("${path.module}/../templates/ocserv.conf", {

  })
}

data "template_file" "script" {
  template = file("${path.module}/../templates/init.sh")

  vars = {
    ocserv_conf   = file("${path.module}/../templates/ocserv.conf")
    ocserv_socket = file("${path.module}/../templates/ocserv.socket")
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "cloud-init.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.init.rendered
  }
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.script.rendered
  }

}


# rh01-VM
resource "azurerm_virtual_machine" "rh01-vm" {
  name                = "${var.projectPrefix}-rh01-vm"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  network_interface_ids = [azurerm_network_interface.rh01-nic.id]
  vm_size               = var.instanceType

  storage_os_disk {
    name              = "${var.projectPrefix}-rhOsDisk"
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
    storage_uri = azurerm_storage_account.rhvm_storageaccount.primary_blob_endpoint
  }

  os_profile {
    computer_name  = "rh01"
    admin_username = var.adminUserName
    admin_password = var.adminPassword
    custom_data    = data.template_cloudinit_config.cloud_init.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}
resource "local_file" "onboard_init" {
  content  = data.template_file.init.rendered
  filename = "${path.module}/../outputs/cloud-rendered.yaml"
}
resource "local_file" "onboard_script" {
  content  = data.template_file.script.rendered
  filename = "${path.module}/../outputs/script.sh"
}
