# This code reads project configurations from YAML files, merges them with module-level variables
# extracts information about project names, labels, APIs to enable, IAM bindings, and service accounts. 
#It organizes this information into various local variables (maps and lists) in main.tf to create and configure GCP projects
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

  # Base project configuration with defaults
  base_project_configs = {
    for name, cfg in local.decoded_configs :
    name => {
        team             = var.team
        environment      = cfg.project.environment
        primary_location = try(cfg.project.primary_location, "")
        description      = cfg.project.description
        folder_id        = var.folder_id
        billing_account  = var.billing_account
        labels          = try(cfg.project.labels, {})
        additional_apis = try(cfg.additional_apis, [])
      }
  }

  # Generate project names using consistent naming convention
  project_names = {
    for name, cfg in local.base_project_configs :
    name => lower(join("-", compact([
      cfg.team,
      cfg.environment,
      "prj",
      cfg.primary_location != "" ? cfg.primary_location : null,
      cfg.description
    ])))
  }

  # Standardized labels for all projects
  project_labels = {
    for name, cfg in local.base_project_configs :
    name => merge(
      cfg.labels,
      {
        team        = cfg.team
        environment = cfg.environment
        managed_by  = "terraform"
        created_by  = "terraform-project-factory"
      }
    )
  }

  # Combined API list per project
  project_apis = {
    for name, cfg in local.base_project_configs :
    name => distinct(concat(var.activate_apis, cfg.additional_apis))
  }

  # Flattened project-API pairs for google_project_service resources
  project_api_pairs = flatten([
    for name, apis in local.project_apis : [
      for api in apis : {
        key         = "${name}-${api}"
        config_file = name
        project_id  = google_project.project[name].project_id
        api         = api
      }
    ]
  ])

  # Convert to map for easier resource creation
  project_api_map = {
    for pair in local.project_api_pairs :
    pair.key => pair
  }

  # Process IAM bindings with validation
  project_iam_bindings = flatten([
    for name, cfg in local.decoded_configs : [
      for role, members in try(cfg.iam_bindings, {}) : {
        key         = "${name}-${role}"
        config_file = name
        role        = startswith(role, "roles/") ? role : "roles/${role}"
        members     = tolist(members)
        project_id  = google_project.project[name].project_id
      }
    ]
  ])

  # Convert to map for resource creation
  project_iam_map = {
    for binding in local.project_iam_bindings :
    binding.key => binding
  }

  # Process service accounts with enhanced metadata
  service_accounts = flatten([
    for name, cfg in local.decoded_configs : [
      for sa_name, sa_cfg in try(cfg.service_accounts, {}) : {
        key         = "${name}-${sa_name}"
        config_file = name
        account_id  = substr(
          lower(
            replace(
              replace("${local.base_project_configs[name].team}-${local.base_project_configs[name].environment}-${sa_name}", "_", "-"),
              "/[^a-z0-9-]/", ""
            )
          ),
          0, 30
        )
        sa_name     = sa_name
        display_name = try(sa_cfg.display_name, title(replace(sa_name, "-", " ")))
        description = try(sa_cfg.description, "Service account for ${sa_name}")
        project_id  = google_project.project[name].project_id
        roles       = try(sa_cfg.roles, [])
        # Include project metadata for consistency
        team        = local.base_project_configs[name].team
        environment = local.base_project_configs[name].environment
        location    = local.base_project_configs[name].primary_location
      }
    ]
  ])

  # Convert to map for resource creation
  service_account_map = {
    for sa in local.service_accounts :
    sa.key => sa
  }

  # Service account IAM bindings with proper role formatting
  sa_iam_bindings = flatten([
    for sa in local.service_accounts : [
      for role in sa.roles : {
        key        = "${sa.key}-${role}"
        config_file = sa.config_file
        sa_name    = sa.sa_name
        role       = startswith(role, "roles/") ? role : "roles/${role}"
        project_id = sa.project_id
        email      = google_service_account.service_accounts[sa.key].email
      }
    ]
  ])

  # Convert to map for resource creation
  sa_iam_map = {
    for binding in local.sa_iam_bindings :
    binding.key => binding
  }

  # Summary for outputs/debugging
  project_summary = {
    for name, cfg in local.base_project_configs :
    name => {
      project_name = local.project_names[name]
      project_id   = google_project.project[name].project_id
      apis_count   = length(local.project_apis[name])
      sa_count     = length([for sa in local.service_accounts : sa if sa.config_file == name])
      iam_bindings_count = length([for binding in local.project_iam_bindings : binding if binding.config_file == name])
    }
  }
}

output "Summary" {
  description = "Project summary"
  value = local.project_summary
}