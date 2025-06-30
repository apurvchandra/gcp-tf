#module "platform_dev" {
#  source = "../../modules/project-factory"
#
#  # Core naming variables 
#  team             = "plt"
#  environment      = "dev"
#  primary_location = "europe-west2" # location is not mandatory
#  description      = "apig" # override happening in yaml file
#  #based on this project id will be plt-dev-prj-apig
#  
#  # Organization structure
#  folder_id       = var.folder_id
#  billing_account = var.billing_account
#  
#  # YAML config will be loaded from:
#  config_files = [
#    "config/dev/dev.yaml",
#    "config/test/test.yaml",
#    # ... more files ...
#  ]  
#}


locals {
  # Discover YAML files based on pattern or explicit list
  config_files = var.config_files != null ? var.config_files : fileset(var.config_path, var.config_pattern)
  
  # Read and decode all YAML files
  environment_configs = {
    for file in local.config_files :
    trimsuffix(basename(file), ".yaml") => yamldecode(file(
      var.config_files != null ? file : "${var.config_path}/${file}"
    ))
  }

  # Filter environments based on enabled flag
  enabled_environments = {
    for env_name, config in local.environment_configs :
    env_name => config
    if try(local.environment_configs[env_name].enabled, true) == true
  }
}

# Create projects using the base module
module "gcp_projects" {
  source = "../../modules/project-factory"  # Path to Project factory

  for_each = local.enabled_environments

  # Pass processed configuration to base module
  environment      = try(each.value.project.environment, "plt")
  team            = try(each.value.project.team, var.default_team)
  primary_location = try(each.value.project.primary_location, "")
  description     = try(each.value.project.description, "deflt")
  folder_id       = try(each.value.project.folder_id, var.folder_id)
  billing_account = try(each.value.project.billing_account, var.billing_account)
    
  # APIs and services
  activate_apis = distinct(concat(
    var.default_apis,
    try(each.value.project.additional_apis, [])
  ))
  
  
  # Pass the config file for the base module to process
  config_files = ["${var.config_path}/${each.key}.yaml"]

}

# Optional: Create budgets for each project
resource "google_billing_budget" "project_budgets" {
  for_each = {
    for env_name, config in local.enabled_environments :
    env_name => config
    if config.budget != null
  }

  billing_account = var.billing_account
  display_name    = "Budget for ${each.key} environment"

  amount {
    specified_amount {
      currency_code = try(each.value.budget.currency, "GBP")
      units         = tostring(try(each.value.budget.amount, 100))
    }
  }

  budget_filter {
    projects = ["projects/${module.gcp_projects[each.key].project_ids["${each.key}.yaml"]}"]
  }

  dynamic "threshold_rules" {
    for_each = try(each.value.budget.thresholds, [0.5, 0.8, 1.0])
    content {
      threshold_percent = threshold_rules.value
      spend_basis      = "CURRENT_SPEND"
    }
  }

  dynamic "all_updates_rule" {
    for_each = try(each.value.budget.notifications, []) != [] ? [1] : []
    content {
      pubsub_topic                     = try(each.value.budget.pubsub_topic, null)
      schema_version                   = "1.0"
      monitoring_notification_channels = try(each.value.budget.notification_channels, [])
    }
  }
}


## Optional: Create monitoring alerts
#resource "google_monitoring_alert_policy" "project_alerts" {
#  for_each = {
#    for env_name, config in local.enabled_environments :
#    "${env_name}-${alert_name}" => {
#      env_name = env_name
#      project_id = module.gcp_projects[env_name].project_id
#      alert_name = alert_name
#      alert_config = alert_config
#    }
#    for alert_name, alert_config in try(config.monitoring.alerts, {})
#  }
#
#  project      = each.value.project_id
#  display_name = each.value.alert_config.display_name
#  combiner     = try(each.value.alert_config.combiner, "OR")
#  enabled      = try(each.value.alert_config.enabled, true)
#
#  conditions {
#    display_name = each.value.alert_config.condition.display_name
#    condition_threshold {
#      filter          = each.value.alert_config.condition.filter
#      duration        = try(each.value.alert_config.condition.duration, "300s")
#      comparison      = try(each.value.alert_config.condition.comparison, "COMPARISON_GREATER_THAN")
#      threshold_value = try(each.value.alert_config.condition.threshold, 0.8)
#    }
#  }
#
#  dynamic "notification_channels" {
#    for_each = try(each.value.alert_config.notification_channels, [])
#    content {
#      notification_channels = notification_channels.value
#    }
#  }
#}
