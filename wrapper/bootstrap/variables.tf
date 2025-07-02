variable "organization_id" {
  description = "The ID of the GCP organization"
  type        = string
}

variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default = ""
}

variable "folder_id" {
  description = "The name of folder"
  type        = string
  default = "value"
}