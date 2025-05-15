output "vpc_network_id" {
  description = "The ID of the VPC network"
  value       = module.infra.vpc_network_id
}

output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = module.infra.vpc_network.name
}

output "managed_domain_zone" {
  description = "Managed Domain zone"
  value       = length(module.domain) > 0 ? module.domain[0].managed_domain_zone : null
}

output "alb_ips" {
  description = "The external IPs for the ALB"
  value =  module.infra.alb_ips
}

output "nlb_ips" {
  description = "The external IPs for the NLB"
  value = module.infra.nlb_ips
}

locals {
  instance_yaml_content = {
    timestamp = timestamp() # Adds the current timestamp to the YAML file
    version   = "1"
    instances = flatten([
      for subnet in module.infra.sub_networks : [
        {
          name     = "${local.name}-${subnet.region}"
          type     = "google"
          pool     = 0
          limit    = 1000
          platform = {
            os   = "linux"
            arch = "amd64"
          }
          spec = {
            tags     = local.vm_tags
            account = {
              project_id = local.project_id
              no_service_account = true
              json_path  = var.service_account_key_file
            }
            image        = local.runner_image
            subnetwork      = subnet.id       # Use the subnet ID here
            network         = module.infra.vpc_network_id
            private_ip: true
            disk = {
              size = 100
              type = "pd-balanced"
            }
          }
        }
      ]
    ])
  }
}

# Output the generated YAML structure
output "instance_yaml" {
  value = yamlencode(local.instance_yaml_content)
  sensitive = false
}

output "sub_networks" {
  value =  module.infra.sub_networks
}

# Write the YAML structure to a file using the local-exec provisioner
resource "null_resource" "write_yaml" {
  triggers = {
    instance_yaml_content = yamlencode(local.instance_yaml_content)
  }

  provisioner "local-exec" {
    command = "echo '${yamlencode(local.instance_yaml_content)}' > pool.yaml"
  }
}