variable "parent_type" {
  description = "The parent type for the tag key: organization, folder, or project"
  type        = string
  validation {
    condition     = contains(["organization", "folder", "project"], var.parent_type)
    error_message = "parent_type must be one of 'organization', 'folder', or 'project'."
  }
}

variable "parent_id" {
  description = "The ID of the parent (organization ID, folder ID, or project ID)"
  type        = string
}

variable "tags" {
  description = <<EOF
A map of tag keys to lists of tag values.
Example:
  tags = {
    "env"  = ["prod", "dev", "test"]
    "team" = ["platform", "security"]
  }
EOF
  type = map(list(string))
}

# Define the structure for IAM bindings on tag keys
variable "tag_key_iam" {
  description = "A map defining IAM roles and members for specific tag keys."
  type = map(object({
    roles = map(list(string)) # Map of roles to a list of members
  }))
  default = {}
}