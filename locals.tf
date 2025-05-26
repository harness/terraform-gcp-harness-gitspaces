
locals {
  project_id = local.infra_config.project.id
  name = local.infra_config.name
  infra_config = yamldecode(file(var.infra_config_yaml_file))
  domain = local.infra_config.domain
  runner_image = local.infra_config.runner.vm_image
  vm_tags = local.infra_config.gitspace_vm_tags
  runner_vm_region = local.infra_config.runner_vm_region
}