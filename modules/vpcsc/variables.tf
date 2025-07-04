variable "org_id" {
  description = "Organization ID for the GCP org"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+$", var.org_id))
    error_message = "Organization ID must be a numeric string."
  }  
}

variable "folder_ids" {
  description = "The folder ID to search for projects under"
  type        = list(string)
}

variable "access_policy_title" {
  description = "Title for the access policy"
  type        = string
  default     = "Orgnization Access Policy"
}

variable "perimeter_name" {
  description = "Name for the service perimeter"
  type        = string
  default     = "Orgnization_perimeter"
}

variable "perimeter_title" {
  description = "Title for the service perimeter"
  type        = string
  default     = "Orgnization Service Perimeter"
}

variable "scopes" {
  description = "List of scopes for the access policy, it can be folders or projects"
  type = list(string) 
  default = [  ]
}

variable "restricted_projects" {
  description = "List of project resource names to restrict (e.g. projects/1234567890)"
  type        = list(string)
  
}

variable "restricted_services" {
  description = "List of restricted Google services"
  type        = list(string)
  default     = ["storage.googleapis.com", "bigquery.googleapis.com"]
}

variable "allowed_ip_subnets" {
  description = "List of CIDR blocks allowed in the IP-based access level"
  type        = list(string)
  default     = []
}

variable "allowed_members" {
  description = "List of allowed members in the member-based access level"
  type        = list(string)
  default     = []
}

variable "egress_resources" {
  description = "List of resource names allowed for egress (e.g., projects/1234567890)"
  type        = list(string)
  default     = []
}

variable "ingress_source_project" {
  description = "Resource name of the source project allowed for ingress"
  type        = string
  default     = ""
}

variable "query" {
  description = "A string query as defined in the [Query Syntax](https://cloud.google.com/asset-inventory/docs/query-syntax)."
  type        = string
  default     = "state:ACTIVE"  
}

variable "excluded_projects" {
  description = "list of projects to exclude from the perimeter"
  type        = list(string)
  default     = []
}

variable "egress_policies" {
  description = "List of egress policy blocks to apply to the perimeter"
  type = list(object({
    egress_to = object({
      resources   = optional(list(string))
      operations  = optional(list(object({
        service_name     = string
        method_selectors = optional(list(object({ method = string })), [])
      })), [])
    })
    egress_from = optional(object({
      identity_type = string
      identities    = optional(list(string), [])
    }), null)
  }))
  default = []
}

variable "ingress_policies" {
  description = "List of ingress policy blocks to apply to the perimeter"
  type = list(object({
    ingress_from = object({
      sources = list(object({
        resource     = optional(string)
        access_level = optional(string)
      }))
    })
    ingress_to = object({
      resources  = list(string)
      operations = optional(list(object({
        service_name     = string
        method_selectors = optional(list(object({ method = string })), [])
      })), [])
    })
  }))
  default = []
}