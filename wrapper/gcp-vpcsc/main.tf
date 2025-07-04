locals {
  config = yamldecode(file(var.config_file_path))
}


module "org-vpcsc" {
  # Adjust the source path if your vpcsc module is located elsewhere
  # relative to this wrapper module.
  source = "../../modules/vpcsc"

  # Required variables - an error will occur if these are not in the YAML file.
  org_id     = local.config.org_id
  folder_ids  = try(local.config.folder_ids, null)

  # Optional variables - if not in YAML, 'null' or "" is passed,
  # and the child module will use its own default values.
  scopes                 = try(local.config.scopes, null)
  restricted_projects    = try(local.config.restricted_projects, null)
  access_policy_title    = try(local.config.access_policy_title, null)
  perimeter_name         = try(local.config.perimeter_name, null)
  perimeter_title        = try(local.config.perimeter_title, null)
  restricted_services    = try(local.config.restricted_services, null)
  allowed_ip_subnets     = try(local.config.allowed_ip_subnets, [])
  allowed_members        = try(local.config.allowed_members, [])
  egress_resources       = try(local.config.egress_resources, null)
  ingress_source_project = try(local.config.ingress_source_project, null)
  excluded_projects      = try(local.config.excluded_projects, [])
  query                  = try(local.config.query, "state:ACTIVE")
}
