terraform {
  backend "gcs" {
    bucket  = "Project_id" # update this
    prefix  = "terraform/state"
  }
}