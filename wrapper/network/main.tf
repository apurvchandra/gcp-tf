locals {
  config               = yamldecode(file("${path.module}/config.yaml"))
  org_fw_policies      = yamldecode(file("${path.module}/org-hier-firewall.yaml"))
  regional_fw_policies = yamldecode(file("${path.module}/regional-firewall.yaml"))
}



module "network" {
  source       = "../../modules/network"
  network_name = local.config.network_name
  subnet_name  = local.config.subnet_name
  subnet_cidr  = local.config.subnet_cidr
  routing_mode = local.config.routing_mode
  project_id   = local.config.spoke_project_id
  region       = local.config.region
}

module "Org_firewall_policies" {
  for_each = { for policy in local.org_fw_policies.firewall_policies : policy.name => policy }

  source             = "../../modules/firewall_policy"
  name               = each.value.name
  scope              = each.value.scope
  parent_id          = lookup(each.value, "parent_id", "")
  region             = lookup(each.value, "region", null)
  association_target = each.value.association_target
  rules              = each.value.rules
}

module "regional_firewall_policies" {
  for_each = { for policy in local.regional_fw_policies.firewall_policies : policy.name => policy }

  source             = "../../modules/firewall_policy"
  name               = each.value.name
  scope              = each.value.scope
  parent_id          = lookup(each.value, "parent_id", "")
  region             = lookup(each.value, "region", null)
  association_target = module.network.hub_vpc_self_link
  rules              = each.value.rules
}

module "ncc" {
  source               = "../../modules/ncc"
  ncc_hub_name         = local.config.ncc_hub_name
  ncc_hub_description  = local.config.ncc_hub_description
  spoke_name           = local.config.spoke_name
  apigee_vpc_self_link = module.network.hub_vpc_self_link
  hub_project_id       = local.config.project_id
  spoke_project_id     = local.config.spoke_project_id
  region               = local.config.region
}

