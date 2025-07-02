variable "ncc_hub_name" {
  type    = string
  default = "apigee-ncc-hub"
}

variable "ncc_hub_description" {
  type    = string
  default = "NCC hub for Apigee X connectivity"
}

variable "spoke_name" {
  type    = string
  default = "apigee-spoke"
}

variable "apigee_vpc_self_link" {
  type = string
}

variable "hub_project_id" {
  type = string
}

variable "spoke_project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "export_psc" {
  type = bool
  default = true
}