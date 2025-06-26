resource "google_org_policy_policy" "constraints" {
  for_each = local.constraints_map

  name   = "${var.organization_id}/policies/${each.value.name}" 
  parent = "${var.organization_id}"

  spec {
    dynamic "rules" {
      for_each = each.value.rules
      content {
        enforce = try(rules.value.enforce, null)

        dynamic "condition" {
          for_each = try(rules.value.condition, null) != null ? [rules.value.condition] : []
          content {
            expression  = try(condition.value.expression, null)
            description = try(condition.value.description, null)
            title       = try(condition.value.title, null)
          }
        }

        # If using list-based policy components:
        dynamic "values" {
          for_each = try(rules.value.values, null) != null ? [rules.value.values] : []
          content {
            allowed_values = try(values.value.allowed_values, null)
            denied_values  = try(values.value.denied_values, null)
          }
        }
      }
    }

    inherit_from_parent = false
    reset               = false
  }
}

output "constraints_map" {
  value = local.constraints_map
}