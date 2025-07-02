variable "type" {
  description = "The type of log sink."
  type        = string  
}
variable "name" {
  description = "The name of the log sink."
  type        = string
}

variable "parent" {
  description = "The parent resource from which to export logs. Must be in the format 'organizations/org_id', 'folders/folder_id', or 'projects/project_id'."
  type        = string
  validation {
    condition     = can(regex("^(organizations|folders|projects)/[^/]+$", var.parent))
    error_message = "Parent must be in the format 'organizations/org_id', 'folders/folder_id', or 'projects/project_id'."
  }
}

variable "destination" {
  description = "The export destination for the sink. Examples: 'storage.googleapis.com/[BUCKET_ID]', 'bigquery.googleapis.com/projects/[PROJECT_ID]/datasets/[DATASET_ID]', 'pubsub.googleapis.com/projects/[PROJECT_ID]/topics/[TOPIC_ID]'."
  type        = string
}

variable "project" {
  description = "Project ID where the sink resource's configuration is stored. For organization/folder sinks, this is typically the central logging project. For project-level sinks, this value is ignored as the sink is configured in the source project itself. If null for org/folder sinks, it defaults to the provider's host project."
  type        = string
  default     = null
}

variable "filter" {
  description = "The advanced logs filter to apply. If empty, all logs are exported."
  type        = string
  default     = ""
}

variable "description" {
  description = "A description of this sink."
  type        = string
  default     = null
}

variable "disabled" {
  description = "If set to true, then this sink is disabled and it does not export any log entries."
  type        = bool
  default     = false
}

variable "unique_writer_identity" {
  description = "Whether or not to create a unique service account for this sink. If false, a shared service account is used. If true, a dedicated service account is created for this sink. This is applicable only for project sinks."
  type        = bool
  default     = false # Defaulting to false as it's only used by project_sink.
}

variable "include_children" {
  description = "Whether to include logs from children of this resource. Only applicable to organization and folder sinks. Defaults to false if not set."
  type        = bool
  default     = null # Provider defaults to false if not set for org/folder sinks.
}

variable "bigquery_options" {
  description = "BigQuery options for the sink (e.g., { use_partitioned_tables = true })."
  type = object({
    use_partitioned_tables = bool
  })
  default = null
}

variable "exclusions" {
  description = "Log entries that match any of these exclusion filters will not be exported."
  type = list(object({
    name        = string
    description = optional(string)
    filter      = string
    disabled    = optional(bool, false)
  }))
  default = []
}
