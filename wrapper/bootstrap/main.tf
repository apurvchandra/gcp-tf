module "project_policy" {
  source            = "../../modules/org_policies/project_policy"
  project_id        = var.project_id
  constraints_path  = "${path.module}/policy_config/project_constraints"
}

module "folder_policy" {
  source            = "../../modules/org_policies/folder_policy"
  folder_id         = var.folder_id
  constraints_path  = "${path.module}/policy_config/folder_constraints"
}

module "org_tags" {
  source      = "../../modules/tags"
  parent_id  = var.organization_id
  parent_type = "organization"
  tags = {
    "env"  = ["prod", "dev", "test"]
    "team" = ["platform", "security"]
  }
}

