# modules/project-factory/variables.tf

variable "team" {
  description = "Team name (first part of naming pattern)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.team)) && length(var.team) <= 10
    error_message = "Team name must be lowercase alphanumeric with hyphens, max 10 characters."
  }
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "primary_location" {
  description = "Primary location/region for resources"
  type        = string
  default     = "europe-west2"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.primary_location))
    error_message = "Location must be a valid GCP region format."
  }
}

variable "description" {
  description = "Description/purpose of the project (used in naming)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.description)) && length(var.description) <= 10
    error_message = "Description must be lowercase alphanumeric with hyphens, max 10 characters."
  }
}

variable "folder_id" {
  description = "The folder ID to create the project in"
  type        = string
}

variable "billing_account" {
  description = "The billing account to associate with the project"
  type        = string
}

variable "project_id" {
  description = "Override project ID (optional)"
  type        = string
  default     = ""
}

variable "config_files" {
  type = list(string)
  default = []
  description = "List of paths to YAML configuration files. If empty, defaults to a single file based on environment."
}

variable "activate_apis" {
  description = "Base APIs to enable (additional APIs can be specified in YAML)"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbilling.googleapis.com"
  ]
}