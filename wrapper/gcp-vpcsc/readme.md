# 🛡️ Terraform VPC Service Controls Wrapper Module

This Terraform module is a **wrapper** around the `vpcsc` module, which configures [Google Cloud VPC Service Controls](https://cloud.google.com/vpc-service-controls). It loads configuration values from a YAML file to make your deployment flexible and manageable.

---

## 📁 Structure

```
.
├── main.tf
├── variables.tf
├── README.md
├── config.yaml         # User-defined configuration
└── ../../modules/vpcsc # Actual VPC SC module
```

---

## 🔧 Usage

### 1. Create a `config.yaml`

```yaml
org_id: "000000000000"          # ✅ Required: GCP Organization ID
access_policy_title: "complexgl_access_policy"
perimeter_name: "complexgl_perimeter"
perimeter_title: "complexgl_perimeter"
folder_id: "88"                 # Optional: Folder containing projects

excluded_projects:
  - "projects/343107750719"

allowed_ip_subnets:
  - "34.79.169.228/32"

# Optional values (uncomment to use)

# scopes:
#   - "folders/1234567890"

# restricted_projects:
#   - "projects/your-project-id"

# restricted_services:
#   - "storage.googleapis.com"
#   - "bigquery.googleapis.com"

# allowed_members:
#   - "user:user@example.com"

# egress_resources:
#   - "projects/external-project-123"

# ingress_source_project: "projects/source-project-id"
```

---

### 2. Terraform Code

```hcl
locals {
  config = yamldecode(file(var.config_file_path))
}

module "org-vpcsc" {
  source = "../../modules/vpcsc"

  org_id                  = local.config.org_id
  folder_id               = try(local.config.folder_id, null)

  scopes                  = try(local.config.scopes, null)
  restricted_projects     = try(local.config.restricted_projects, null)
  access_policy_title     = try(local.config.access_policy_title, null)
  perimeter_name          = try(local.config.perimeter_name, null)
  perimeter_title         = try(local.config.perimeter_title, null)
  restricted_services     = try(local.config.restricted_services, null)
  allowed_ip_subnets      = try(local.config.allowed_ip_subnets, [])
  allowed_members         = try(local.config.allowed_members, [])
  egress_resources        = try(local.config.egress_resources, null)
  ingress_source_project  = try(local.config.ingress_source_project, null)
  excluded_projects       = try(local.config.excluded_projects, [])
  query                   = try(local.config.query, "state:ACTIVE")
}
```

---

## 📌 Inputs

| Name                   | Description                                           | Required | Default         |
|------------------------|-------------------------------------------------------|----------|-----------------|
| `config_file_path`     | Path to the YAML configuration file                   | ✅       | N/A             |
| `org_id`               | GCP Organization ID                                   | ✅       | —               |
| `folder_id`            | Folder containing scoped projects                     | ❌       | `null`          |
| `scopes`               | Scope folders/projects for access policy              | ❌       | module default  |
| `restricted_projects`  | Projects to include manually in the perimeter         | ❌       | module default  |
| `access_policy_title`  | Title of the access policy                            | ❌       | module default  |
| `perimeter_name`       | Name of the perimeter                                 | ❌       | module default  |
| `perimeter_title`      | Title of the perimeter                                | ❌       | module default  |
| `restricted_services`  | GCP services to restrict                              | ❌       | module default  |
| `allowed_ip_subnets`   | Allowed IPs for perimeter ingress                     | ❌       | `[]`            |
| `allowed_members`      | Allowed IAM members for ingress                       | ❌       | `[]`            |
| `egress_resources`     | Allowed egress resources                              | ❌       | `null`          |
| `ingress_source_project` | Project allowed for ingress                        | ❌       | `null`          |
| `excluded_projects`    | Projects to exclude from the perimeter                | ❌       | `[]`            |
| `query`                | Project discovery query (used in child module)        | ❌       | `"state:ACTIVE"`|

---

## ▶️ Run the Module

```bash
terraform init
terraform plan -var="config_file_path=./config.yaml"
terraform apply -var="config_file_path=./config.yaml"
```

---

## 📎 Notes

- The `yamldecode(file(...))` function reads the YAML file at runtime.
- All required values must be provided in the config file or Terraform will fail.
- Optional values default to null/empty and fall back to the child module's defaults.

---

## 📚 Resources

- [VPC Service Controls Documentation](https://cloud.google.com/vpc-service-controls/docs)
- [Terraform Google Provider Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

