locals {
  # Load sinks from YAML file
  logging_settings     = var.logging_settings
  sinks_yaml = yamldecode(file("${path.module}/${var.config_file_path}.yaml"))
  logging_sinks = try(local.sinks_yaml.sinks, {})
}

resource "google_storage_bucket" "org_logs_bucket" {
 name    = "${var.project_id}-org-logs-bucket"
 location = var.location
 project = var.project_id

 uniform_bucket_level_access = true

 lifecycle_rule {
   action {
     type = "Delete"
   }
   condition {
     age = 10
   }
 }
}

module "logging_sinks" {
  for_each = { for sink in local.logging_sinks : sink.name => sink }

  source = "../../modules/logging"

  name                   = each.value.name
  type                   = each.value.type
  parent                 = each.value.parent
  destination            = each.value.destination
  filter                 = each.value.filter
  description            = each.value.description
  disabled               = each.value.disabled
  include_children       = try(each.value.include_children, false)
  unique_writer_identity = try(each.value.unique_writer_identity, null)
  bigquery_options       = try(each.value.bigquery_options, null)
  exclusions             = try(each.value.exclusions, [])
  project                = try(each.value.project, null)
}


