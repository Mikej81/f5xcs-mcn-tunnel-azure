# main.tf

# Util Module
# - Random Prefix Generation
# - Random Password Generation
module "util" {
  source = "./util"
}

# Azure Module
# Create all Azure Dependencies
module "azure" {
  source        = "./azure"
  projectPrefix = module.util.env_prefix
  location      = var.location
  region        = var.region
  namespace     = var.namespace
  cidr          = var.cidr
  subnets       = var.azure_subnets
  adminPassword = module.util.admin_password
  tags          = var.tags
  name          = lower(var.name)
  source_net    = module.util.local_public_ip
}

# Volterra Module
# Build Site Token and Cloud Credential
# Build out Azure Site
module "volterra" {
  source = "./volterra"

  depends_on = [
    module.azure.azure_resource_group_main, module.azure.azure_virtual_network_main, module.azure.azure_subnet_internal, module.azure.azure_subnet_external
  ]
  name                      = var.name
  namespace                 = var.namespace
  azure_resource_group_name = module.azure.azure_resource_group_main.name
  resource_group_name       = "${module.util.env_prefix}_xcs_rg"
  fleet_label               = var.fleet_label
  url                       = var.api_url
  api_p12_file              = var.api_p12_file
  region                    = var.region
  location                  = var.location
  projectPrefix             = module.util.env_prefix
  sshPublicKeyPath          = var.sshPublicKeyPath
  sshPublicKey              = var.sshPublicKey
  azure_client_id           = var.azure_client_id
  azure_client_secret       = var.azure_client_secret
  azure_tenant_id           = var.azure_tenant_id
  xcs_tenant                = var.tenant_name
  azure_subscription_id     = var.azure_subscription_id
  gateway_type              = var.gateway_type
  volterra_tf_action        = var.volterra_tf_action
  existing_vnet             = module.azure.azure_virtual_network_main
  cidr                      = var.cidr
  azure_subnets             = var.azure_subnets
  subnet_internal           = module.azure.azure_subnet_internal
  subnet_external           = module.azure.azure_subnet_external
  delegated_domain          = var.delegated_dns_domain
  tags                      = var.tags
}

module "remotehost" {
  source           = "./remotehost"
  location         = var.location
  region           = var.region
  resource_group   = module.azure.azure_resource_group_main
  projectPrefix    = module.util.env_prefix
  security_group   = module.azure.azurerm_network_security_group_rh
  rhSubnet         = module.azure.azure_subnet_internal
  publicip         = module.azure.azurerm_public_ip
  publicip_id      = module.azure.azurerm_public_ip_id
  dns_server       = var.dns_server
  adminUserName    = var.adminUserName
  adminPassword    = module.util.admin_password
  rh01ip           = var.rh01ip
  internal_subnet  = var.azure_subnets["internal"]
  tags             = var.tags
  timezone         = var.timezone
  instanceType     = var.appInstanceType
  name             = var.name
  sshPublicKeyPath = var.sshPublicKeyPath
  sshPublicKey     = var.sshPublicKey
}
