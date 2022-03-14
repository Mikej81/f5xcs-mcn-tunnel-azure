terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.3"
    }
  }
}

resource "volterra_token" "new_site" {
  name      = format("%s-sca-token", var.name)
  namespace = "system"

  #labels = var.tags
}

output "token" {
  value = volterra_token.new_site.id
}

resource "volterra_cloud_credentials" "azure_site" {
  name      = format("%s-azure-credentials", var.name)
  namespace = "system"
  #labels    = var.tags
  azure_client_secret {
    client_id       = var.azure_client_id
    subscription_id = var.azure_subscription_id
    tenant_id       = var.azure_tenant_id
    client_secret {
      clear_secret_info {
        url = "string:///${base64encode(var.azure_client_secret)}"
      }
    }

  }
}

output "credentials" {
  value = volterra_cloud_credentials.azure_site.name
}

resource "volterra_virtual_network" "inside" {
  name      = format("%s-inside", var.name)
  namespace = "system"

  site_local_inside_network = true
}
resource "volterra_virtual_network" "outside" {
  name      = format("%s-outside", var.name)
  namespace = "system"

  site_local_network = true
}
resource "volterra_virtual_network" "global" {
  name      = format("%s-global", var.name)
  namespace = "system"

  global_network = true
}

resource "volterra_network_connector" "snat" {
  name      = format("%s-connector-snat", var.name)
  namespace = "system"

  sli_to_global_snat {
    global_vn {
      name      = volterra_virtual_network.global.name
      namespace = "system"
      #tenant    = var.volterra_tenant
    }
    snat_config {
      interface_ip    = true
      dynamic_routing = true
    }
  }

  disable_forward_proxy = true
}
resource "volterra_network_connector" "direct" {
  name      = format("%s-connector-direct", var.name)
  namespace = "system"

  sli_to_global_dr {
    global_vn {
      name      = volterra_virtual_network.global.name
      namespace = "system"
      #tenant    = var.volterra_tenant
    }

  }

  disable_forward_proxy = true
}

resource "volterra_azure_vnet_site" "azure_site" {
  name      = format("%s-vnet-site", var.name)
  namespace = "system"
  labels = {
    concentrator = "true"
  }

  depends_on = [
    var.subnet_internal, var.subnet_external, volterra_voltstack_site.stack, volterra_k8s_cluster.cluster
  ]

  azure_region = var.location
  #resource_group = var.resource_group_name
  resource_group = var.resource_group_name
  ssh_key        = file(var.sshPublicKeyPath)

  machine_type = "Standard_D3_v2"

  #assisted = true
  azure_cred {
    name      = volterra_cloud_credentials.azure_site.name
    namespace = "system"
  }

  # new error when no worker nodes?
  # nodes_per_az = 1
  no_worker_nodes = true
  # worker_nodes = 0

  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true

  vnet {

    existing_vnet {
      resource_group = var.azure_resource_group_name
      vnet_name      = var.existing_vnet.name
    }

  }

  ingress_egress_gw {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"
    // azure-byol-multi-nic-voltmesh

    no_forward_proxy = true
    #no_global_network = true
    #no_inside_static_routes  = true
    no_network_policy        = true
    no_outside_static_routes = true

    global_network_list {
      global_network_connections {
        sli_to_global_dr {
          global_vn {
            #tenant    = var.volterra_tenant
            namespace = "system"
            name      = volterra_virtual_network.global.name
          }
        }
      }

    }

    az_nodes {
      azure_az = "1"

      outside_subnet {
        subnet {
          subnet_resource_grp = var.azure_resource_group_name
          vnet_resource_group = true
          subnet_name         = "external"
        }
      }

      inside_subnet {
        subnet {
          subnet_resource_grp = var.azure_resource_group_name
          vnet_resource_group = true
          subnet_name         = "internal"
        }
      }

    }

  }

}

resource "volterra_tf_params_action" "action_test" {
  site_name       = volterra_azure_vnet_site.azure_site.name
  site_kind       = "azure_vnet_site"
  action          = var.volterra_tf_action
  wait_for_action = true
}

data "azurerm_resources" "volterra_resource_group" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name = var.resource_group_name
}

data "azurerm_network_interface" "sli" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                = "master-0-sli"
  resource_group_name = var.resource_group_name
}

output "azure_network_interface_sli_ip" {
  value = data.azurerm_network_interface.sli.private_ip_address
}

# Create RT-0
resource "azurerm_route_table" "route_table" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                          = "rt-0"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = false
}

resource "azurerm_route" "default" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                = "default-route"
  resource_group_name = var.resource_group_name

  route_table_name       = azurerm_route_table.route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = data.azurerm_network_interface.sli.private_ip_address
}

resource "azurerm_subnet_route_table_association" "associate" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  subnet_id      = var.subnet_internal.id
  route_table_id = azurerm_route_table.route_table.id
}

data "azurerm_network_security_group" "security_group" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                = "security-group"
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "external_association" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  subnet_id                 = var.subnet_external.id
  network_security_group_id = data.azurerm_network_security_group.security_group.id
}

resource "azurerm_subnet_network_security_group_association" "internal_association" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  subnet_id                 = var.subnet_internal.id
  network_security_group_id = data.azurerm_network_security_group.security_group.id
}

output "volterra_resource_group" {
  value = data.azurerm_resources.volterra_resource_group
}

output "volterra_resource_group_tags" {
  value = merge(var.tags, { vesio_site_name = "${volterra_azure_vnet_site.azure_site.name}" })
}
