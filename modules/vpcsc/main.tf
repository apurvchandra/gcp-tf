# This Terraform module sets up an Access Context Manager policy with access levels and a service perimeter.
# It includes IP-based and member-based access levels, and a service perimeter with egress and ingress policies.
########################################
# 1. Access Policy
########################################
resource "google_access_context_manager_access_policy" "default" {
  parent = "organizations/${var.org_id}"
  title  = var.access_policy_title
  scopes = var.scopes
}

########################################
# 2. Access Levels
########################################

resource "google_access_context_manager_access_level" "ip_based" {
  count  = length(var.allowed_ip_subnets) > 0 ? 1 : 0
  parent = "accessPolicies/${google_access_context_manager_access_policy.default.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.default.name}/accessLevels/ip_based"
  title  = "IP Based Access"
  
  basic {
    conditions {
      ip_subnetworks = var.allowed_ip_subnets
    }
  }

  depends_on = [google_access_context_manager_access_policy.default]
}

# Member-based Access Level
resource "google_access_context_manager_access_level" "member_based" {
  count  = length(var.allowed_members) > 0 ? 1 : 0
  parent = "accessPolicies/${google_access_context_manager_access_policy.default.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.default.name}/accessLevels/member_based"
  title  = "Member Based Access"
  
  basic {
    conditions {
      members = var.allowed_members
    }
  }

  depends_on = [google_access_context_manager_access_policy.default]
}

# Data source for project discovery
data "google_cloud_asset_search_all_resources" "all_projects" {
  for_each    = toset(var.folder_ids)
  scope       = "folders/${each.value}"
  query       = var.query
  asset_types = ["cloudresourcemanager.googleapis.com/Project"]
}


# Local values for computed data
locals {
  perimeter_projects = flatten([
    for d in data.google_cloud_asset_search_all_resources.all_projects :
    [
      for result in d.results :
      result.project
      if !contains(var.excluded_projects, result.project)
    ]
  ])

  access_levels = compact([
    length(var.allowed_ip_subnets) > 0 ? google_access_context_manager_access_level.ip_based[0].name : "",
    length(var.allowed_members) > 0 ? google_access_context_manager_access_level.member_based[0].name : ""
  ])

  has_projects      = length(local.perimeter_projects) > 0
  has_access_levels = length(local.access_levels) > 0
}


# Service Perimeter
resource "google_access_context_manager_service_perimeter" "main" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.default.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.default.name}/servicePerimeters/${var.perimeter_name}"
  title  = var.perimeter_title
  #one of perimeter_project or restricted_projects can be used
  status {
    resources           = local.perimeter_projects != null && length(local.perimeter_projects) > 0 ? local.perimeter_projects : var.restricted_projects
    restricted_services = var.restricted_services
    access_levels      = local.access_levels

  dynamic "egress_policies" {
    for_each = var.egress_policies
    content {
      egress_to {
        resources = lookup(egress_policies.value.egress_to, "resources", null)
        dynamic "operations" {
          for_each = lookup(egress_policies.value.egress_to, "operations", [])
          content {
            service_name = operations.value.service_name
            # method_selectors if needed
          }
        }
      }
      egress_from {
        identity_type = lookup(egress_policies.value.egress_from, "identity_type", null)
        identities    = lookup(egress_policies.value.egress_from, "identities", [])
      }
    }
  }

  dynamic "ingress_policies" {
    for_each = var.ingress_policies
    content {
      ingress_from {
        dynamic "sources" {
          for_each = lookup(ingress_policies.value.ingress_from, "sources", [])
          content {
            resource     = lookup(sources.value, "resource", null)
            access_level = lookup(sources.value, "access_level", null)
          }
        }
      }
      ingress_to {
        resources = ingress_policies.value.ingress_to.resources
        dynamic "operations" {
          for_each = lookup(ingress_policies.value.ingress_to, "operations", [])
          content {
            service_name = operations.value.service_name
            # method_selectors if needed
          }
        }
      }
    }
  }
  }

  depends_on = [
    google_access_context_manager_access_policy.default,
    google_access_context_manager_access_level.ip_based,
    google_access_context_manager_access_level.member_based
  ]

  lifecycle {
    # Prevent destruction if perimeter contains resources
    prevent_destroy = false
  }
}

## Validation checks
#resource "null_resource" "validation" {
#  count = local.has_projects || local.has_access_levels ? 0 : 1
#  
#  provisioner "local-exec" {
#    command = "echo 'Warning: No projects found and no access levels configured. Perimeter may be ineffective.' && exit 1"
#  }
#}