module "platform_dev" {
  source = "../../modules/project-factory"

  # Core naming variables
  team             = "plt"
  environment      = "dev"
  primary_location = "euwe2"
  description      = "ts1" # overfide happening in yaml file
  
  # Organization structure
  folder_id       = var.folder_id
  billing_account = var.billing_account
  
  # YAML config will be automatically loaded from:
  #google-project/dev/platform.yaml
  config_files = [
    "config/dev/dev.yaml",
    "config/test/test.yaml",
    # ... more files ...
  ]  
}

