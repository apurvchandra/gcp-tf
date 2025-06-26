variable "org_id" {
  description = "Organization ID for the GCP org"
  type        = string
}

variable "project_id" {
  description = "Project ID for the target project"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
  default     = "europe-west2"
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
  type = list(string) 
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
  default     = [""]
}

variable "allowed_members" {
  description = "List of allowed members in the member-based access level"
  type        = list(string)
  default     = ["user:"]
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