This module creates Google Cloud Platform (GCP) firewall policies and rules. It supports both hierarchical firewall policies (for organizations and folders) and regional network firewall policies (for VPC networks).

**Key Features:**

*   **Hierarchical and Regional Policies:**  Create firewall policies at the organization, folder, or regional level.
*   **Firewall Rules:** Define rules with configurable priority, action (allow/deny), direction (ingress/egress), logging, IP ranges, protocols, ports, and target service accounts.
*   **Policy Association:** Associate the firewall policy with a specific resource (e.g., a VPC network, folder, organization, or project).

**To use this module, you will need to provide the following information:**

*   `name`:  A name for the firewall policy.
*   `scope`: The scope of the policy ("organization", "folder", or "regional").
*   `parent_id`: The ID of the organization or folder (for hierarchical policies) or the project ID (for regional policies).
*   `rules`: A list of firewall rule objects, each with the following attributes:
    *   `description`: Description of the rule.
    *   `priority`:  Rule priority (lower number = higher priority).
    *   `direction`:  "INGRESS" or "EGRESS".
    *   `action`:  "allow" or "deny".
    *   `enable_logging`:  Boolean to enable logging for the rule.
    *   `src_ip_ranges` (optional): List of source IP ranges (for ingress rules).
    *   `dest_ip_ranges` (optional): List of destination IP ranges (for egress rules).
    *   `ip_protocol`:  IP protocol (e.g., "tcp", "udp", "icmp").
    *   `ports`: List of ports or port ranges.
    *   `target_resources` (optional): List of target resources to apply the rule to.
    *   `target_service_accounts` (optional): List of target service accounts to apply the rule to.
*   `association_target`: The resource to associate the policy with (e.g., a VPC network's self_link for regional policies, or a folder/organization ID for hierarchical policies).
*   `region` (optional): The region for regional firewall policies (defaults to "us-central1").

**Example:**

```terraform
module "firewall_policy" {
  source  = "./modules/firewall_policy"  # Replace with the actual path to the module

  name        = "my-firewall-policy"
  scope       = "regional"
  parent_id   = "your-project-id"
  association_target = "your-vpc-network-self-link" # e.g., "projects/your-project-id/global/networks/your-network"
  rules = [
    {
      description     = "Allow SSH from specific IP"
      priority        = 1000
      direction       = "INGRESS"
      action          = "allow"
      enable_logging  = true
      src_ip_ranges   = ["203.0.113.0/24"]
      ip_protocol     = "tcp"
      ports           = ["22"]
    },
    {
      description     = "Deny all outbound traffic"
      priority        = 2000
      direction       = "EGRESS"
      action          = "deny"
      enable_logging  = false
      ip_protocol     = "all"
      ports           = []
    }
  ]
}

output "firewall_policy_name" {
  value = module.firewall_policy.policy_name
}
