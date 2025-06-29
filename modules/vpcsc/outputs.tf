# Outputs for reference
output "access_policy_id" {
  description = "The ID of the access policy"
  value       = google_access_context_manager_access_policy.default.id
}

output "perimeter_name" {
  description = "The name of the service perimeter"
  value       = google_access_context_manager_service_perimeter.main.name
}

output "protected_projects" {
  description = "List of projects protected by the perimeter"
  value       = local.perimeter_projects
}

output "access_levels" {
  description = "List of access levels applied to the perimeter"
  value       = local.access_levels
}

output "perimeter_projects" {
  description = "List of projects included in the perimeter"
  value       = local.perimeter_projects 
}