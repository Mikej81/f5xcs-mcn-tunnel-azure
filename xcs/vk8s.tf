## vk8s

resource "volterra_virtual_site" "vsite_connector" {
  name      = format("%s-vsite", var.name)
  namespace = var.namespace

  site_selector {
    expressions = ["concentrator in (true)"]
  }

  site_type = "CUSTOMER_EDGE"
}

resource "volterra_virtual_k8s" "vk8s_concentrator" {
  name      = format("%s-vk8s-site", var.name)
  namespace = var.namespace
  vsite_refs {
    name      = volterra_virtual_site.vsite_connector.name
    namespace = var.namespace
  }
}
