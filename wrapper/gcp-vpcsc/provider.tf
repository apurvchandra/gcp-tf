terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.40"
    }
  }
  backend "gcs" {
    bucket = "algebraic-ward-263914_tf"
    prefix = "org-vpcsc-test"
    
  }
}