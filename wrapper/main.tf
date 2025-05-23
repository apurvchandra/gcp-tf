module "project_policy" {
  source            = "../modules/project_policy"
  project_id        = var.project_id
  constraints_path  = "${path.module}/override/project_constraints"
}

module "folder_policy" {
  source            = "../modules/folder_policy"
  folder_id         = var.folder_id
  constraints_path  = "${path.module}/override/folder_constraints"
}