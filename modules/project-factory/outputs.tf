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

