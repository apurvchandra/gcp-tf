# GCP Landing Zone Terraform

This repository **will** provide a modular and scalable Terraform-based implementation of a **Google Cloud Landing Zone**. It follows best practices from the Google Cloud Foundation Toolkit (CFT) to help organizations bootstrap, organize, and secure their GCP environments.

Note: 

## 📁 Repository Structure

### `wrappers/`
Contains high-level orchestration layers for each stage of the landing zone setup:

- `bootstrap/` – Initializes the GCP org, Terraform backend, and CI/CD pipeline.
- `organisation/` – Sets up folders, org policies, and logging at the organization level.
- `environments/` – Creates dev, nonprod, and prod environments.
- `networks-svpc/` – Configures Shared VPCs per environment.
- `networks-hub-and-spoke/` – Implements a hub-and-spoke network architecture.

### `modules/`
Reusable Terraform modules that encapsulate actual GCP resources:

- `project_factory/` – Creates GCP projects with APIs and IAM.
- `shared_vpc/` – Sets up Shared VPCs and service project attachments.
- `vpc_service_controls/` – Defines VPC-SC perimeters and access levels.
- `org_policies/`, `folders/`, `iam_bindings/`, etc. – Manage org-level resources and security.
- `firewall_rules/`, `interconnect/` – Network and connectivity components.


## 🚀 Getting Started

1. Clone the repository.
2. Start with `wrappers/bootstrap` to initialize the backend.
3. Apply each wrapper stage in order to build out the full landing zone.

## 🧱 Requirements

- Terraform >= 1.3
- Google Cloud CLI
- Access to a GCP Organization and Billing Account

## 📌 Notes

- All modules are designed to be reusable and environment-agnostic.
- Wrapper layers provide opinionated orchestration for consistency and scalability.
