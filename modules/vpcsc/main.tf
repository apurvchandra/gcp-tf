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
#data "google_access_context_manager_access_policy" "existing" {
  #parent = "organizations/${var.org_id}"
#}

########################################
# 2. Access Levels
########################################

resource "google_access_context_manager_access_level" "ip_based" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.default.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.default.name}/accessLevels/ip_based"
  title  = "IP Based Access"
  basic {
    conditions {
      ip_subnetworks = var.allowed_ip_subnets
    }
  }
}

resource "google_access_context_manager_access_level" "member_based" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.default.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.default.name}/accessLevels/member_based"
  title  = "Member Based Access"
  basic {
    conditions {
      members = var.allowed_members
    }
  }
}

########################################
# 3. 
########################################
# Find all projects in an organization (or folder)
data "google_cloud_asset_search_all_resources" "all_projects" {
  scope = "folders/966051568825" # Or "organizations/${var.org_id}" folders/XXXXXX"
  query = "name:test*"
  asset_types = [
    "cloudresourcemanager.googleapis.com/Project"
  ]
}

# Transform project IDs to resource format required by perimeter
locals {
  perimeter_projects = [
    for p in data.google_cloud_asset_search_all_resources.all_projects.results :
    "projects/${p.project}"
  ]
}


########################################
# 4. Service Perimeter with Egress/Ingress Policies
########################################

resource "google_access_context_manager_service_perimeter" "main" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.default.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.default.name}/servicePerimeters/${var.perimeter_name}"
  title  = var.perimeter_title

  status {
    resources           = var.restricted_projects
    restricted_services = var.restricted_services
    access_levels = [
      google_access_context_manager_access_level.ip_based.name,
      google_access_context_manager_access_level.member_based.name
    ]
    # Example: Allow egress from perimeter to a specific external project

    dynamic "egress_policies" {
      for_each = try(length(var.egress_resources), 0) > 0 ? [1] : []
      content {
        egress_to {
          resources = var.egress_resources
          operations {
            service_name = "*"
          }
        }
        egress_from {
          identity_type = "ANY_IDENTITY"
        }
      }
    }

    dynamic "ingress_policies" {
      for_each = try(length(var.ingress_source_project), 0) > 0 ? [1] : []
      content {
        ingress_from {
          sources {
            resource = var.ingress_source_project
          }
        }
        ingress_to {
          operations {
            service_name = "*"
          }
        }
      }
    }
  }
}
