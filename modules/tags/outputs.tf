# Outputs for reference
output "tag_keys" {
  value = { for k, v in google_tags_tag_key.default : k => v.name }
}

output "tag_values" {
  value = { for k, v in google_tags_tag_value.default : k => v.name }
}

#output "tag_bindings" {
#  value = { for k, v in google_tags_tag_binding.default : k => v.name }
#}