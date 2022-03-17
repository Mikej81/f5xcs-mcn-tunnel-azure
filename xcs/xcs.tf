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

resource "volterra_virtual_network" "global" {
  name      = format("%s-global-network", var.name)
  namespace = "system"

  global_network = true
}

resource "volterra_network_connector" "direct" {
  name      = format("%s-connector-cloud", var.name)
  namespace = "system"

  slo_to_global_dr {
    global_vn {
      name      = volterra_virtual_network.global.name
      namespace = "system"
      #tenant    = var.volterra_tenant
    }

  }

  disable_forward_proxy = true
}
resource "volterra_network_connector" "local" {
  name      = format("%s-connector-fleet", var.name)
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

output "xcs_global_connector_local" {
  value = volterra_network_connector.local.name
}

resource "volterra_azure_vnet_site" "azure_site" {
  name      = format("%s-vnet-site", var.name)
  namespace = "system"
  labels = {
    concentrator = "true"
  }

  azure_region = var.location

  resource_group = var.resource_group_name
  ssh_key        = file(var.sshPublicKeyPath)

  machine_type = "Standard_D3_v2"

  azure_cred {
    name      = volterra_cloud_credentials.azure_site.name
    namespace = "system"
  }

  no_worker_nodes = true

  logs_streaming_disabled = true

  vnet {

    new_vnet {
      autogenerate = true
      primary_ipv4 = var.cidr
    }

  }

  ingress_egress_gw {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"

    no_forward_proxy        = true
    no_inside_static_routes = true
    no_network_policy       = true
    #no_outside_static_routes = true

    outside_static_routes {
      static_route_list {
        simple_static_route = "8.8.8.8/32"
      }
      static_route_list {
        simple_static_route = "8.8.4.4/32"
      }
      static_route_list {
        simple_static_route = "128.0.0.0/1"
      }
      static_route_list {
        simple_static_route = "0.0.0.0/1"
      }
    }

    global_network_list {
      global_network_connections {
        slo_to_global_dr {
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
        subnet_param {
          ipv4 = var.azure_subnets["external"]
        }
      }

      inside_subnet {
        subnet_param {
          ipv4 = var.azure_subnets["internal"]
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
