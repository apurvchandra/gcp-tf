locals {
  constraints_files = fileset(var.constraints_path, "*.yaml")

  constraints_map = merge([
    for file in local.constraints_files : {
      for idx, constraint in yamldecode(file("${var.constraints_path}/${file}")).constraints :
      "${file}-${idx}" => {
        name  = constraint.name
        rules = constraint.rules
      }
    }
  ]...)
}
