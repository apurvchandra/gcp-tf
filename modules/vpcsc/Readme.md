# VPC Service Controls Terraform Module

This module (`modules/vpcsc/main.tf`) is part of the [`apurvchandra/gcp-tf`](https://github.com/apurvchandra/gcp-tf) repository. It provisions [Google Cloud VPC Service Controls](https://cloud.google.com/vpc-service-controls/) using Terraform, including Access Context Manager policies, access levels, and service perimeters with customizable ingress and egress rules.

---

## Features

- **Access Context Manager Policy**: Creates a policy scoped to your organization.
- **Access Levels**: Supports both IP-based and member-based access levels.
- **Project Discovery**: Optionally discovers projects in a folder or organization.
- **Service Perimeter**: Configurable perimeter with support for egress and ingress rules.
- **Dynamic Policies**: Enables dynamic configuration for ingress and egress policies.

---

## Usage

```hcl
module "vpcsc" {
  source = "../modules/vpcsc" # Adjust path as necessary

  org_id                = "123456789012"
  access_policy_title   = "My Access Policy"
  scopes                = ["organizations/123456789012"]
  allowed_ip_subnets    = ["10.0.0.0/8"]
  allowed_members       = ["user:admin@example.com"]
  perimeter_name        = "my-perimeter"
  perimeter_title       = "My Perimeter"
  restricted_projects   = ["projects/my-project"]
  restricted_services   = ["bigquery.googleapis.com"]
  egress_resources      = ["projects/egress-project"]
  ingress_source_project = ["projects/ingress-project"]
}
```

---

## Inputs

| Variable                  | Description                                                        | Type     | Example                       | Required |
|---------------------------|--------------------------------------------------------------------|----------|-------------------------------|----------|
| `org_id`                  | GCP Organization ID                                                | string   | `"123456789012"`              | Yes      |
| `access_policy_title`     | Title for Access Context Manager Policy                            | string   | `"My Access Policy"`          | Yes      |
| `scopes`                  | Scopes for the access policy                                      | list     | `["organizations/123456789012"]` | Yes  |
| `allowed_ip_subnets`      | List of IP subnets for IP-based access level                      | list     | `["10.0.0.0/8"]`              | Yes      |
| `allowed_members`         | List of members for member-based access level                     | list     | `["user:admin@example.com"]`  | Yes      |
| `perimeter_name`          | Name for the service perimeter                                    | string   | `"my-perimeter"`              | Yes      |
| `perimeter_title`         | Title for the service perimeter                                   | string   | `"My Perimeter"`              | Yes      |
| `restricted_projects`     | List of project resource IDs to restrict                          | list     | `["projects/my-project"]`     | Yes      |
| `restricted_services`     | List of GCP services to restrict                                  | list     | `["bigquery.googleapis.com"]` | Yes      |
| `egress_resources`        | List of resources for egress policy (optional)                    | list     | `["projects/egress-project"]` | No       |
| `ingress_source_project`  | List of source projects for ingress policy (optional)             | list     | `["projects/ingress-project"]`| No       |

---

## Outputs

This module does not explicitly define outputs, but you can add outputs as needed in your root module to expose resource attributes.

---

## Notes

- **Project Discovery**: The module contains a data source to discover projects in a folder or organization. You may need to modify the `scope` and `query` in the `data "google_cloud_asset_search_all_resources" "all_projects"` block to suit your needs.
- **Dynamic Policies**: Egress and ingress policies are added only if corresponding variables are provided.
- **Service Perimeter**: The `restricted_projects` and `restricted_services` must be provided to define the perimeter scope.

---

## Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.10
- [Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest) >= 6.10
- Permissions to create Access Context Manager policies, access levels, and VPC Service Controls in your GCP organization.

---

## References

- [Google VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/access_context_manager_service_perimeter)
- [Terraform Access Context Manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/access_context_manager_access_policy)
