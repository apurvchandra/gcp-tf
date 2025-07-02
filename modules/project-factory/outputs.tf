output "project_ids" {
  description = "The GCP project IDs created from each config file"
  value = {
    for name, project in google_project.project :
    name => project.project_id
  }
}

output "project_names" {
  description = "The display names of the projects"
  value = {
    for name, project in google_project.project :
    name => project.name
  }
}

# Example: Output service account information
output "service_accounts" {
  description = "Created service accounts"
  value = {
    for key, sa in google_service_account.service_accounts : key => {
      name         = sa.name
      email        = sa.email
      display_name = sa.display_name
      unique_id    = sa.unique_id
      project      = sa.project
    }
  }
}

output "service_account_emails" {
  description = "Service account emails by config file and SA name"
  value = {
    for key, sa in local.service_account_map : 
    "${sa.config_file}/${sa.sa_name}" => google_service_account.service_accounts[key].email
  }
}