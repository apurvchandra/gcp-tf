variable "organization_id_numeric" {
  description = "The numeric organization ID."
  type        = string
  default = null
}

variable "type" {
 description = "Logging type"
 type = string
 default = "logging" 
}

variable "location" {
 description = "Location of bucket"
 type = string
 default = "europe-west2" 
}

variable "project_id" {
  description = "The ID of the logging project."
  type        = string
  default = ""
}

variable "logging_settings" {
  description = <<-EOT
    Optional logging organization settings, e.g.:
    {
      disable_default_sink = true,
      storage_location     = "us"
    }
  EOT
  type    = object({
    disable_default_sink = optional(bool)
    storage_location     = optional(string)
  })
  default = null
}

variable "logging_data_access" {
  description = <<-EOT
    Optional map of data access audit configs, e.g.:
    {
      "allServices" = {
        "ADMIN_READ" = {
          exempted_members = []
        }
        "DATA_READ" = {
          exempted_members = []
        }
      }
    }
  EOT
  type    = map(map(object({
    exempted_members = list(string)
  })))
  default = {}
}

variable "logging_exclusions" {
  description = "Optional map of log exclusion filters, keyed by exclusion name."
  type        = map(string)
  default     = {}
}

variable "config_file_path" {
  description = "Path to the YAML file containing log sink configurations."
  type        = string
  default     = "config/logging_sinks"
}