variable "name" {
  type        = string
  description = "The name of the firewall policy"
}

variable "description" {
  type        = string
  description = "Description for the policy"
  default     = ""
}

variable "scope" {
  type        = string
  description = "Scope of the policy: organization, folder, or regional"
  validation {
    condition     = contains(["organization", "folder", "regional"], var.scope)
    error_message = "Scope must be one of: organization, folder, regional."
  }
}

variable "parent_id" {
  type        = string
  description = "Organization or folder ID (for hierarchical policies)"
  default     = ""
}

variable "region" {
  type        = string
  description = "Region for regional firewall policy"
  default     = "us-central1"
}

variable "rules" {
  description = "List of firewall rules"
  type = list(object({
    description     = string
    priority        = number
    direction       = string
    action          = string
    enable_logging  = bool
    src_ip_ranges   = optional(list(string))
    dest_ip_ranges  = optional(list(string))
    ip_protocol     = string
    ports           = list(string)
    target_resources       = optional(list(string))
    target_service_accounts = optional(list(string))
  }))
}

variable "association_target" {
  type        = string
  description = "The resource to associate the policy with. For regional: VPC network. For hierarchical: folder, org, or project."
}
