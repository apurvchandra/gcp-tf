locals {
  is_regional = var.scope == "regional"
}

resource "google_compute_firewall_policy" "hierarchical" {
  count        = local.is_regional ? 0 : 1
  short_name   = var.name
  parent       = var.scope == "organization" ? "organizations/${var.parent_id}" : "folders/${var.parent_id}"
  description  = var.description
}

resource "google_compute_firewall_policy_rule" "hierarchical_rules" {
  for_each = local.is_regional ? {} : {
    for rule in var.rules : rule.priority => rule
  }

  firewall_policy = google_compute_firewall_policy.hierarchical[0].name
  priority        = each.value.priority
  action          = each.value.action
  direction       = each.value.direction
  enable_logging  = each.value.enable_logging
  description     = each.value.description

    match {
    src_ip_ranges  = each.value.direction == "INGRESS" ? each.value.src_ip_ranges : null
    dest_ip_ranges = each.value.direction == "EGRESS" ? try(each.value.dest_ip_ranges, null) : null

    layer4_configs {
        ip_protocol = each.value.ip_protocol
        ports       = each.value.ports
    }
    }

  target_resources         = try(each.value.target_resources, null)
  target_service_accounts  = try(each.value.target_service_accounts, null)
}

resource "google_compute_firewall_policy_association" "hierarchical" {
  count            = local.is_regional ? 0 : 1
  name             = "${var.name}-assoc"
  firewall_policy  = google_compute_firewall_policy.hierarchical[0].name
  attachment_target = var.association_target
}

resource "google_compute_region_network_firewall_policy" "regional" {
  count       = local.is_regional ? 1 : 0
  name        = var.name
  region      = var.region
  project     = var.parent_id
  description = var.description
}

resource "google_compute_region_network_firewall_policy_rule" "regional_rules" {
  for_each = local.is_regional ? {
    for rule in var.rules : rule.priority => rule
  } : {}

  firewall_policy = google_compute_region_network_firewall_policy.regional[0].name
  priority        = each.value.priority
  action          = each.value.action
  direction       = each.value.direction
  enable_logging  = each.value.enable_logging
  description     = each.value.description
  region          = var.region
  project         = var.parent_id

match {
  src_ip_ranges  = each.value.direction == "INGRESS" ? each.value.src_ip_ranges : null
  dest_ip_ranges = each.value.direction == "EGRESS" ? try(each.value.dest_ip_ranges, null) : null

  layer4_configs {
    ip_protocol = each.value.ip_protocol
    ports       = each.value.ports
  }
}

  target_service_accounts = try(each.value.target_service_accounts, null)
}

resource "google_compute_region_network_firewall_policy_association" "regional_assoc" {
  count            = local.is_regional ? 1 : 0
  name             = "${var.name}-assoc"
  firewall_policy  = google_compute_region_network_firewall_policy.regional[0].name
  attachment_target = var.association_target
  region           = var.region
  project          = var.parent_id
}