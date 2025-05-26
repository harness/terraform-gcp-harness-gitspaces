# Domain Module Documentation

## Module Usage
Module to create infrastructure in GCP for running Harness Gitspaces – includes creation of VPCs, Subnetworks, IAM, Cloud NAT, and supporting services.


## Terraform Variables
### Terraform Inputs
| Variable Name                 | Type   | Description                                                                                  | Required | Default / Validation |
| ----------------------------- | ------ | -------------------------------------------------------------------------------------------- | -------- | -------------------- |
| `infra_config_yaml_file`      | string | The path to the YAML file containing infrastructure configuration.                           | Yes      | —                    |
| `use_gcp_certificate_manager` | bool   | Use Google Certificate Manager for SSL certificates.                                         | No       | `true`               |
| `private_key_path`            | string | Path to the private key file for SSL certificate. Required if not using Certificate Manager. | No       | `""`                 |
| `certificate_path`            | string | Path to the SSL certificate file. Required if not using Certificate Manager.                 | No       | `""`                 |


## Terraform Outputs

| Output Name           | Description         | Value / Reference                          | Notes                |
| --------------------- | ------------------- | ------------------------------------------ | -------------------- |
| `managed_domain_zone` | Managed Domain zone | `google_dns_managed_zone.default.dns_name` | DNS name of the zone |

### Example:

```hcl
module "domain" {
  infra_config_yaml_file      = var.infra_config_yaml_file
  project_id                  = local.project_id
  use_gcp_certificate_manager = var.use_gcp_certificate_manager
}```