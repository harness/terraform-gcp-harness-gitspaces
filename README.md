# harness-gitspaces-gcp

Module to create infrastructure in GCP for running Harness Gitspaces – includes creation of VPCs, Subnetworks, IAM, Cloud NAT, and supporting services.

### Prerequisite

You must have a GCP project with the following APIs enabled:

- **Cloud Resource Manager API** – `api/cloudresourcemanager.googleapis.com`
- **Compute Engine API** – `api/compute.googleapis.com`
- **Certificate Manager API** – `api/certificatemanager.googleapis.com`
- **Identity and Access Management (IAM) API** – `api/iam.googleapis.com`
- **Cloud DNS API** – `api/dns.googleapis.com`


Gateway:
- Creation service account for gateway deployment
- Instance Group
- Instance Template
- Update Backend Service for ALB and NLB

## Terraform Variables
### Terraform Inputs

| Variable Name                  | Type    | Description                                                                                          | Required | Default / Validation                                                      |
|-------------------------------|---------|------------------------------------------------------------------------------------------------------|----------|----------------------------------------------------------------------------|
| `service_account_key_file`    | string  | The path to the service account key file.                                                            | Yes      | —                                                                          |
| `infra_config_yaml_file`      | string  | The path to the YAML file containing infrastructure configuration.                                   | Yes      | —                                                                          |
| `action`                      | string  | The environment action to perform. Options: `create_infrastructure_only`, `deploy_gateway`.          | Yes      | Must be one of: `["create_infrastructure_only", "deploy_gateway"]`        |
| `manage_dns_zone`             | bool    | Whether the DNS zone should be managed by the module.                                                | Yes      | —                                                                          |
| `use_gcp_certificate_manager` | bool    | Use Google Certificate Manager for SSL certificates.                                                 | No       | `true`                                                                     |
| `private_key_path`            | string  | Path to the private key file for SSL certificate. Required if not using Certificate Manager.         | No       | `""`                                                                       |
| `certificate_path`            | string  | Path to the SSL certificate file. Required if not using Certificate Manager.                         | No       | `""`                                                                       |

## Terraform Outputs

| Output Name         | Description                               | Value / Reference                        | Notes                                  |
|---------------------|-------------------------------------------|------------------------------------------|----------------------------------------|
| `vpc_network_id`     | The ID of the VPC network                 | `module.infra.vpc_network_id`            | Used to identify the created VPC       |
| `vpc_network_name`   | The name of the VPC network               | `module.infra.vpc_network.name`          | Human-readable VPC name                |
| `alb_ips`            | The external IPs for the ALB             | `module.infra.alb_ips`                   | List of IPs assigned to the ALB        |
| `nlb_ips`            | The external IPs for the NLB             | `module.infra.nlb_ips`                   | List of IPs assigned to the NLB        |
| `instance_yaml`      | YAML-encoded runner instance config       | `yamlencode(local.instance_yaml_content)`| Encoded YAML structure for VMs         |
| `sub_networks`       | List of subnetwork objects                | `module.infra.sub_networks`              | Contains subnet ID, region, etc.       |


### Example:
```hcl
module "harness_gitspacs_gcp" {
  source                      = "" # Add the path to the module
  infra_config_yaml_file      = "infra_config.yaml"
  service_account_key_file    = "service-account-key.json"
  action                      = "deploy_gateway"
  manage_dns_zone             = true
  use_gcp_certificate_manager = true
  certificate_path            = "sample_domain.cert"
  private_key_path            = "sample_domain.key"
}
```