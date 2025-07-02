#output "project_summary" {
#  value = module.platform_dev.Summary
#}

#output "projects" {
#  description = "All created projects with their details"
#  value = {
#    for env_name, project in module.gcp_projects :
#    env_name => {
#      project_id     = project.project_id
#      project_name   = project.project_name
#      project_number = project.project_number
#      apis_enabled   = project.enabled_apis
#      service_accounts = try(project.service_accounts, {})
#    }
#  }
#}
#
#output "project_ids" {
#  description = "Map of environment names to project IDs"
#  value = {
#    for env_name, project in module.gcp_projects :
#    env_name => project.project_id
#  }
#}
#
#output "service_accounts" {
#  description = "All service accounts created across environments"
#  value = {
#    for env_name, project in module.gcp_projects :
#    env_name => try(project.service_accounts, {})
#  }
#}

#output "budgets" {
#  description = "Created budgets for projects"
#  value = {
#    for env_name, budget in google_billing_budget.project_budgets :
#    env_name => {
#      name         = budget.name
#      display_name = budget.display_name
#      amount       = budget.amount
#    }
#  }
#}

output "environment_summary" {
  description = "Summary of all environments and their configuration"
  value = {
    for env_name, config in local.enabled_environments :
    env_name => {
      team             = config.project.team
      environment      = config.project.environment
      primary_location = config.project.primary_location
      project_id       = module.gcp_projects[env_name].Summary
      #apis_count       = length(config.activate_apis)
      has_budget       = config.budget != null
      sa_count         = length(config.service_accounts)
    }
  }
}