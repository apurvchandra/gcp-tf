locals {
  parent = (
    var.parent_type == "organization" ? "organizations/${var.parent_id}" :
    var.parent_type == "folder"       ? "folders/${var.parent_id}" :
    "projects/${var.parent_id}"
  )
  tag_pairs = flatten([
    for tag_key, tag_values in var.tags : [
      for tag_value in tag_values : {
        key = "${tag_key}/${tag_value}"
        value = {
          tag_key   = tag_key
          tag_value = tag_value
        }
      }
    ]
  ])  
}


# Create all tag keys (namespaces)
resource "google_tags_tag_key" "default" {
  for_each   = var.tags
  short_name = each.key
  parent     = local.parent
  
  # Description can be added if needed: description = "Tag key ${each.key}"
}


resource "google_tags_tag_value" "default" {
  for_each = { for pair in local.tag_pairs : pair.key => pair.value }
  parent = google_tags_tag_key.default[each.value.tag_key].id
  short_name = each.value.tag_value
}

# Bind all tag values to the parent (org/folder/project)
resource "google_tags_tag_binding" "default" {
  for_each  = google_tags_tag_value.default
  parent    = "//cloudresourcemanager.googleapis.com/${local.parent}"
  tag_value = each.value.name
}


# Resource to manage IAM Bindings for Tag Keys
#resource "google_tags_tag_key_iam_member" "main" {
#  for_each = {
#    for tag_key_name, iam_config in var.tag_key_iam :
#    tag_key_name => iam_config.roles
#    if contains(keys(google_tags_tag_key.main), tag_key_name)
#  }
#
#  tag_key = google_tags_tag_key.main[each.key].id
#  role    = each.value.role
#  member  = each.value.member
#}
output "tag_pairs" {
  
  value = local.tag_pairs
}
