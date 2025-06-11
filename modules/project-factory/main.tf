resource "google_project" "project" {
  for_each = local.merged_configs

  name                = local.project_names[each.key]
  project_id          = var.project_id != "" ? var.project_id : local.project_names[each.key]
  folder_id           = each.value.folder_id
  billing_account     = each.value.billing_account
  auto_create_network = false

  labels = each.value.labels

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_project_service" "project_services" {
  for_each = {
    for pair in local.project_api_pairs :
    "${pair.config_file}-${pair.api}" => pair
  }

  project = each.value.project_id
  service = each.value.api

  disable_dependent_services = try(local.merged_configs[each.value.config_file].disable_services_on_destroy, false)
  disable_on_destroy         = try(local.merged_configs[each.value.config_file].disable_services_on_destroy, false)

  depends_on = [google_project.project]
}

resource "google_project_iam_binding" "project_iam" {
  for_each = {
    for binding in local.iam_bindings :
    "${binding.config_file}-${binding.role}" => binding
  }

  project = each.value.project_id
  role    = each.value.role
  members = each.value.members

  depends_on = [google_project_service.project_services]
}

resource "google_service_account" "service_accounts" {
  for_each = {
    for sa in local.service_accounts :
    "${sa.config_file}-${sa.sa_name}" => sa
  }

  project      = each.value.project_id
  account_id   = "${each.value.team}-${each.value.environment}-sa-${each.value.location}-${each.value.sa_name}"
  display_name = each.value.sa_config.display_name
  description  = try(each.value.sa_config.description, "Service account for ${each.value.sa_name}")

  depends_on = [google_project_service.project_services]
}

resource "google_project_iam_member" "service_account_iam" {
  for_each = {
    for binding in local.sa_iam_bindings :
    "${binding.config_file}-${binding.sa_name}-${binding.role}" => binding
  }

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.email}"

  depends_on = [google_project_service.project_services]
}
