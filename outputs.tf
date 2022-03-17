## OUTPUTS ###

output "deployment_info" {
  value = {
    config_prefix           = var.name
    deployment_instructions = "Add ${module.xcs.xcs_global_connector_local} global network connector to your local fleet.  Link will not be live until the cloud side has finished provisioning."
  }
}
