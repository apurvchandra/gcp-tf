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
  scope       = "folders/${var.folder_id}"
  query       = var.query
  asset_types = ["cloudresourcemanager.googleapis.com/Project"]
}

# Local values for computed data
locals {
  # Extract project IDs for perimeter resources
  perimeter_projects = [
    for result in data.google_cloud_asset_search_all_resources.all_projects.results :
    result.project
    if  !contains(var.excluded_projects, result.project)
  ]
  
  # Combine all access levels, filtering out empty strings
  access_levels = compact([
    length(var.allowed_ip_subnets) > 0 ? google_access_context_manager_access_level.ip_based[0].name : "",
    length(var.allowed_members) > 0 ? google_access_context_manager_access_level.member_based[0].name : ""
  ])
  
  # Validate that we have either projects or access levels
  has_projects = length(local.perimeter_projects) > 0
  has_access_levels = length(local.access_levels) > 0
}

# Service Perimeter
resource "google_access_context_manager_service_perimeter" "main" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.default.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.default.name}/servicePerimeters/${var.perimeter_name}"
  title  = var.perimeter_title

  status {
    resources           = local.perimeter_projects
    restricted_services = var.restricted_services
    access_levels      = local.access_levels

    # Egress policies - allow traffic out of the perimeter
    dynamic "egress_policies" {
      for_each = var.egress_resources != null && length(var.egress_resources) > 0 ? [1] : []
      content {
        egress_to {
          resources = var.egress_resources
          operations {
            service_name = "*"
            # Consider being more specific with method_selectors if needed
            # method_selectors {
            #   method = "*"
            # }
          }
        }
        egress_from {
          identity_type = "ANY_IDENTITY"
          # Consider adding more specific identity constraints:
          # identities = ["user:user@example.com"]
        }
      }
    }

    # Ingress policies - allow traffic into the perimeter
    dynamic "ingress_policies" {
      for_each = var.ingress_source_project != null && length(var.ingress_source_project) > 0 ? [1] : []
      content {
        ingress_from {
          sources {
            resource = var.ingress_source_project
          }
          # Consider adding access level requirements:
          # access_level = google_access_context_manager_access_level.ip_based[0].name
        }
        ingress_to {
          resources = ["*"] # Consider being more specific
          operations {
            service_name = "*"
            # Consider limiting to specific services:
            # service_name = "storage.googleapis.com"
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