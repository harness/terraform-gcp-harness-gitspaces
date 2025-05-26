## Module Usage
This module is designed to create a managed domain zone in Google Cloud Platform (GCP) for use with Harness Gitspaces. It can also manage SSL certificates using Google Certificate Manager or custom certificates.
## Terraform Variables
### Terraform Inputs
| Variable Name                 | Type   | Description                                                                                  | Required | Default / Validation                                               |
| ----------------------------- | ------ | -------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------ |
| `infra_config_yaml_file`      | string | The path to the YAML file containing infrastructure configuration.                           | Yes      | —                                                                  |
| `use_gcp_certificate_manager` | bool   | Use Google Certificate Manager for SSL certificates.                                         | No       | `true`                                                             |
| `private_key_path`            | string | Path to the private key file for SSL certificate. Required if not using Certificate Manager. | No       | `""`                                                               |
| `certificate_path`            | string | Path to the SSL certificate file. Required if not using Certificate Manager.                 | No       | `""`                                                               |


## Terraform Outputs

| Output Name        | Description                         | Value / Reference                         | Notes                            |
| ------------------ | ----------------------------------- | ----------------------------------------- | -------------------------------- |
| `vpc_network_id`   | The ID of the VPC network           | `module.infra.vpc_network_id`             | Used to identify the created VPC |
| `vpc_network_name` | The name of the VPC network         | `module.infra.vpc_network.name`           | Human-readable VPC name          |
| `alb_ips`          | The external IPs for the ALB        | `module.infra.alb_ips`                    | List of IPs assigned to the ALB  |
| `nlb_ips`          | The external IPs for the NLB        | `module.infra.nlb_ips`                    | List of IPs assigned to the NLB  |
| `instance_yaml`    | YAML-encoded runner instance config | `yamlencode(local.instance_yaml_content)` | Encoded YAML structure for VMs   |
| `sub_networks`     | List of subnetwork objects          | `module.infra.sub_networks`               | Contains subnet ID, region, etc. |

### Example:
```hcl
module "infra" {
infra_config_yaml_file = var.infra_config_yaml_file
project_id = local.project_id
action = var.action
use_gcp_certificate_manager = var.use_gcp_certificate_manager
private_key_path = var.private_key_path
certificate_path = var.certificate_path
}
```