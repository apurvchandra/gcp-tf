locals {
  # If no config file provided, use default path
  config_files = length(var.config_files) > 0 ? var.config_files : ["${path.module}/../../gcp-projects/${var.environment}.yaml"]

  # Basename to file path
  config_file_map = { for path in local.config_files : basename(path) => path }

  # Decode YAML
  decoded_configs = {
    for name, path in local.config_file_map :
    name => yamldecode(fileexists(path) ? file(path) : "{}")
  }

  # Merge config
  merged_configs = {
    for name, cfg in local.decoded_configs :
    name => merge(
      try(cfg.project, {}),
      {
        team             = var.team
        environment      = cfg.project.description
        primary_location = var.primary_location
        description      = cfg.project.description
        folder_id        = var.folder_id
        billing_account  = var.billing_account
      }
    )
  }

  # Project name and labels
  project_names = {
    for name, cfg in local.merged_configs :
    name => "${cfg.team}-${cfg.environment}-prj-${cfg.primary_location}-${cfg.description}"
  }

  labels = {
    for name, cfg in local.merged_configs :
    name => merge(
      try(cfg.labels, {}),
      {
        team        = cfg.team
        environment = cfg.environment
        managed_by  = "terraform"
      }
    )
  }

  # API list
  apis = {
    for name, cfg in local.merged_configs :
    name => concat(var.activate_apis, try(cfg.additional_apis, []))
  }

  project_api_pairs = flatten([
    for name, apis in local.apis : [
      for api in distinct(apis) : {
        config_file = name
        project_id  = google_project.project[name].project_id
        api         = api
      }
    ]
  ])

  # IAM bindings
  iam_bindings = flatten([
    for name, cfg in local.decoded_configs : [
      for role, members in try(cfg.iam_bindings, {}) : {
        config_file = name
        role        = role
        members     = members
        project_id  = google_project.project[name].project_id
      }
    ]
  ])

  # Service accounts
  service_accounts = flatten([
    for name, cfg in local.decoded_configs : [
      for sa_name, sa_cfg in try(cfg.service_accounts, {}) : {
        config_file = name
        sa_name     = sa_name
        sa_config   = sa_cfg
        project_id  = google_project.project[name].project_id
        team        = local.merged_configs[name].team
        environment = local.merged_configs[name].environment
        location    = local.merged_configs[name].primary_location
      }
    ]
  ])

  sa_iam_bindings = flatten([
    for sa in local.service_accounts : [
      for role in try(sa.sa_config.roles, []) : {
        config_file = sa.config_file
        sa_name     = sa.sa_name
        role        = role
        project_id  = sa.project_id
        email       = google_service_account.service_accounts["${sa.config_file}-${sa.sa_name}"].email
      }
    ]
  ])
}

output "config_file_map" {
  value = local.config_file_map
}

output "config_files" {
  value = local.config_files
}

output "merged_configs" {
  value = local.merged_configs
}

output "decoded_configs" {
  value = local.decoded_configs
}
