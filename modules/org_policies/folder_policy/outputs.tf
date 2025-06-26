output "applied_policies" {
  description = "List of applied organization policies"
  value       = keys(google_org_policy_policy.constraints)
}