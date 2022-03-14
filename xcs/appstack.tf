// Stand up a Managed K8s Cluster and an AppStack

resource "volterra_k8s_cluster" "cluster" {
  name      = format("%s-managedk8s-cluster", var.name)
  namespace = "system"

  no_cluster_wide_apps              = true
  use_default_cluster_role_bindings = true
  use_default_cluster_roles         = true
  cluster_scoped_access_permit      = true
  global_access_enable              = true
  no_insecure_registries            = true

  local_access_config {
    local_domain = "cluster.local"
    default_port = true
  }
  use_default_psp = true
}


resource "volterra_voltstack_site" "stack" {
  name      = format("%s-appstack-site", var.name)
  namespace = "system"

  depends_on = [
    volterra_k8s_cluster.cluster
  ]

  no_bond_devices = true
  disable_gpu     = true

  k8s_cluster {
    namespace = "system"
    name      = volterra_k8s_cluster.cluster.name
  }

  logs_streaming_disabled = true

  master_nodes = ["master-0"]

  default_network_config = true

  default_storage_config = true

  deny_all_usb = true
  // aws-byol-multi-nic-voltmesh or azure-byol-multi-nic-voltmesh
  volterra_certified_hw = "azure-byol-multi-nic-voltmesh"
}
