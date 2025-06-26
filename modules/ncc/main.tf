resource "google_network_connectivity_hub" "hub" {
  name        = var.ncc_hub_name
  description = var.ncc_hub_description
  project     = var.hub_project_id
  export_psc = var.export_psc
}

resource "google_network_connectivity_spoke" "apigee_spoke" {
  name        = var.spoke_name
  hub         = google_network_connectivity_hub.hub.id
  location    = "global"
  project     = var.spoke_project_id
  description = "spoke for ${var.spoke_name}"
  linked_vpc_network {
    uri = var.apigee_vpc_self_link
  }
}