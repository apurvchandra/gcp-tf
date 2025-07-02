# modules/gcp-multi-project-wrapper/variables.tf

variable "config_path" {
  description = "Path to directory containing YAML configuration files"
  type        = string
  default     = "./environments"
}

variable "config_pattern" {
  description = "Pattern to match YAML files (used with fileset)"
  type        = string
  default     = "*.yaml"
}

variable "config_files" {
  description = "Explicit list of config file paths (overrides config_path + pattern)"
  type        = list(string)
  default     = null
}

variable "folder_id" {
  description = "Default folder ID for projects"
  type        = string
}

variable "billing_account" {
  description = "Default billing account for projects"
  type        = string
}

variable "default_team" {
  description = "Default team name if not specified in config"
  type        = string
  default     = "plt"
}

variable "default_location" {
  description = "This will be a short name for location identification e.g. euwe2"
  type        = string
  default     = ""
}

variable "default_apis" {
  description = "APIs to enable in all projects by default"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}

variable "default_labels" {
  description = "Default labels to apply to all projects"
  type        = map(string)
  default = {
    managed_by = "terraform"
    source     = "project-wrapper"
  }
}

variable "create_budgets" {
  description = "Whether to create budgets for projects that have budget configuration"
  type        = bool
  default     = true
}

variable "create_monitoring" {
  description = "Whether to create monitoring alerts for projects"
  type        = bool
  default     = true
}

variable "environments_filter" {
  description = "List of environment names to create (empty = all enabled environments)"
  type        = list(string)
  default     = []
}