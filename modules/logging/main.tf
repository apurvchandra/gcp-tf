locals {
  parent_parts = split("/", var.parent)
  parent_type  = local.parent_parts[0] # "organizations", "folders", or "projects"
  parent_id    = local.parent_parts[1]
  type         = var.type

  # For project sinks, the sink is created in the project itself (parent_id).
  # For org/folder sinks, var.project specifies where the sink config is stored.
  # If var.project is null for org/folder sinks, the resource defaults to the provider's configured project.
  sink_management_project = local.parent_type == "projects" ? local.parent_id : var.project
  
}

resource "google_logging_organization_sink" "org_sink" {
  count = local.parent_type == "organizations" ? 1 : 0

  name        = var.name
  org_id      = local.parent_id
  destination = "${local.type}.googleapis.com/${var.destination}"
  #project     = local.sink_management_project # Project to store this sink's config

  filter                 = var.filter
  description            = var.description
  disabled               = var.disabled
  #unique_writer_identity = var.unique_writer_identity
  include_children       = var.include_children

  dynamic "bigquery_options" {
    for_each = var.bigquery_options != null ? [var.bigquery_options] : []
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = var.exclusions
    content {
      name        = exclusions.value.name
      description = try(exclusions.value.description, null)
      filter      = exclusions.value.filter
      disabled    = try(exclusions.value.disabled, false)
    }
  }
}

resource "google_logging_folder_sink" "folder_sink" {
  count = local.parent_type == "folders" ? 1 : 0

  name        = var.name
  folder      = local.parent_id # Note: API uses 'folder', TF resource uses 'folder'
  destination = "${local.type}.googleapis.com/${var.destination}"
  #project     = local.sink_management_project # Project to store this sink's config

  filter                 = var.filter
  description            = var.description
  disabled               = var.disabled
  #unique_writer_identity = var.unique_writer_identity
  include_children       = var.include_children

  dynamic "bigquery_options" {
    for_each = var.bigquery_options != null ? [var.bigquery_options] : []
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = var.exclusions
    content {
      name        = exclusions.value.name
      description = try(exclusions.value.description, null)
      filter      = exclusions.value.filter
      disabled    = try(exclusions.value.disabled, false)
    }
  }
}

resource "google_logging_project_sink" "project_sink" {
  count = local.parent_type == "projects" ? 1 : 0

  name        = var.name
  project     = local.sink_management_project # Project from which logs are exported AND where sink is configured
  destination = var.destination

  filter                 = var.filter
  description            = var.description
  disabled               = var.disabled
  unique_writer_identity = var.unique_writer_identity
  # include_children is not applicable for project sinks

  dynamic "bigquery_options" {
    for_each = var.bigquery_options != null ? [var.bigquery_options] : []
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = var.exclusions
    content {
      name        = exclusions.value.name
      description = try(exclusions.value.description, null)
      filter      = exclusions.value.filter
      disabled    = try(exclusions.value.disabled, false)
    }
  }
}

resource "google_storage_bucket_iam_member" "project_sink-binding" {
  count = local.parent_type == "projects" ? 1 : 0
  bucket   = var.destination
  role     = "roles/logging.logWriter"
  member   = google_logging_project_sink.project_sink[0].writer_identity
}

resource "google_project_iam_member" "project-sinks-binding" {
  count = local.parent_type == "projects" ? 1 : 0
  project  = var.project
  role     = "roles/logging.logWriter"
  member   = google_logging_project_sink.project_sink[0].writer_identity
}

resource "google_storage_bucket_iam_member" "org-sinks-binding" {
  count = local.parent_type == "organizations" ? 1 : 0

  bucket   = var.destination
  role     = "roles/storage.objectCreator"
  member   = google_logging_organization_sink.org_sink[0].writer_identity
}