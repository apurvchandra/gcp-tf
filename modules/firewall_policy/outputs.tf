output "policy_name" {
  value = var.scope == "regional" ? google_compute_region_network_firewall_policy.regional[0].name : google_compute_firewall_policy.hierarchical[0].name
}
