output "access_policy_id" {
  description = "The ID of the access policy created."
  value       = module.org-vpcsc.access_policy_id_
}

output "ip_based_access_level" {
  description = "The name of the IP-based access level created."
  value       = module.org-vpcsc.ip_based_access_level_
}

output "member_based_access_level" {
  description = "The name of the member-based access level created."
  value       = module.org-vpcsc.member_based_access_level_
}

output "service_perimeter" {
  description = "The name of the service perimeter created."
  value       = module.org-vpcsc.service_perimeter_
}

