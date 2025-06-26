module "platform_dev" {
  source = "../../modules/project-factory"

  # Core naming variables 
  team             = "plt"
  environment      = "dev"
  primary_location = "euwe2"
  description      = "apig" # override happening in yaml file
  #based on this project id will be plt-dev-prj-euwe2-ts1
  
  # Organization structure
  folder_id       = var.folder_id
  billing_account = var.billing_account
  
  # YAML config will be loaded from:
  config_files = [
    "config/dev/dev.yaml",
    "config/test/test.yaml",
    # ... more files ...
  ]  
}

