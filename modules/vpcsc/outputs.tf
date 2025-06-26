output "access_policy_id_" {
  value = google_access_context_manager_access_policy.default.name
}

output "ip_based_access_level_" {
  value = google_access_context_manager_access_level.ip_based.name
}

output "member_based_access_level_" {
  value = google_access_context_manager_access_level.member_based.name
}

output "service_perimeter_" {
  value = google_access_context_manager_service_perimeter.main.name
}

#output "asset_search_sample_" {
#  value = data.google_cloud_asset_search_all_resources.all_projects.results[0]
#}