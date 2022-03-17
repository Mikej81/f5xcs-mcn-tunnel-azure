# main.tf

# Util Module
# - Random Prefix Generation
# - Random Password Generation
module "util" {
  source = "./util"
}

# Volterra Module
# Build Site Token and Cloud Credential
# Build out Azure Site
module "xcs" {
  source = "./xcs"

  name                  = var.name
  namespace             = var.namespace
  resource_group_name   = "${module.util.env_prefix}_xcs_rg"
  fleet_label           = var.fleet_label
  url                   = var.api_url
  api_p12_file          = var.api_p12_file
  region                = var.region
  location              = var.location
  projectPrefix         = module.util.env_prefix
  sshPublicKeyPath      = var.sshPublicKeyPath
  sshPublicKey          = var.sshPublicKey
  azure_client_id       = var.azure_client_id
  azure_client_secret   = var.azure_client_secret
  azure_tenant_id       = var.azure_tenant_id
  volterra_tenant       = var.tenant_name
  azure_subscription_id = var.azure_subscription_id
  gateway_type          = var.gateway_type
  volterra_tf_action    = var.volterra_tf_action
  cidr                  = var.cidr
  azure_subnets         = var.azure_subnets
  delegated_domain      = var.delegated_dns_domain
  tags                  = var.tags
}
