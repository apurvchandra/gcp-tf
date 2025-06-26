variable "network_name" {
  type    = string
  default = "apigee-vpc"
}

variable "subnet_name" {
  type    = string
  default = "apigee-subnet"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "routing_mode" {
  type    = string
  default = "REGIONAL"
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}