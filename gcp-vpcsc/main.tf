locals {
  config = yamldecode(file(var.config_file_path))
}

module "org-vpcsc" {
  # Adjust the source path if your vpcsc module is located elsewhere
  # relative to this wrapper module.
  source = "../../modules/vpcsc"

  # Required variables - an error will occur if these are not in the YAML file.
  org_id              = local.config.org_id
  project_id          = local.config.project_id
  scopes              = local.config.scopes
  restricted_projects = local.config.restricted_projects

  # Optional variables - if not in YAML, 'null' is passed,
  # and the child module will use its own default values.
  region                  = try(local.config.region, null)
  access_policy_title     = try(local.config.access_policy_title, null)
  perimeter_name          = try(local.config.perimeter_name, null)
  perimeter_title         = try(local.config.perimeter_title, null)
  restricted_services     = try(local.config.restricted_services, null)
  allowed_ip_subnets      = try(local.config.allowed_ip_subnets, null)
  allowed_members         = try(local.config.allowed_members, null)
  egress_resources        = try(local.config.egress_resources, null)
  ingress_source_project  = try(local.config.ingress_source_project, null)
}