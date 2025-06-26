resource "google_project" "project" {
  for_each = local.base_project_configs

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
  for_each = local.project_api_map

  project = each.value.project_id
  service = each.value.api

  #
  disable_dependent_services = try(local.project_api_map[each.value.config_file].disable_services_on_destroy, false)
  disable_on_destroy         = try(local.project_api_map[each.value.config_file].disable_services_on_destroy, false)

  depends_on = [google_project.project]
}

resource "google_project_iam_binding" "project_iam" {
  for_each = local.project_iam_map

  project = each.value.project_id
  role    = each.value.role
  members = each.value.members

  depends_on = [google_project_service.project_services]
}

# Create service accounts using the service_account_map
resource "google_service_account" "service_accounts" {
  for_each = local.service_account_map

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
  project      = each.value.project_id

  depends_on = [google_project.project]
}

# Assign IAM roles to service accounts using sa_iam_map
resource "google_project_iam_member" "sa_iam_bindings" {
  for_each = local.sa_iam_map

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.email}"

  depends_on = [google_service_account.service_accounts]
}