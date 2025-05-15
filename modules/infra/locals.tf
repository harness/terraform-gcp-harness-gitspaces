
locals {
  account_identifier = local.infra_config.account_identifier
  infra_provider_config_identifier = local.infra_config.infra_provider_config_identifier
  project_id = var.project_id
  name = local.infra_config.name
  network_name = "${local.name}-network"
  infra_config = yamldecode(file(var.infra_config_yaml_file))
  domain = local.infra_config.domain
  region_configs = local.infra_config.region_configs
  vm_tags_gitspace = local.infra_config.gitspace_vm_tags

  gateway_deploy = var.action == "deploy_gateway" ? true : false
  gateway_vm_tags = local.infra_config.gateway.vm_tags
  gateway_machine_type = local.infra_config.gateway.machine_type
  gateway_instances = local.infra_config.gateway.instances
  gateway_vm_image_family = local.infra_config.gateway.vm_image.family
  gateway_vm_image_project = local.infra_config.gateway.vm_image.project
  provisioner_service_account = local.infra_config.project.service_account # Service account used to deploy gateway
  gateway_secret = local.infra_config.gateway.shared_secret
  gateway_version = local.infra_config.gateway.version
  cde_manager_url = local.infra_config.gateway.cde_manager_url
  vm_ip_ranges = lookup(local.infra_config.gateway, "whitelist_ip_ranges", ["0.0.0.0/0"])
}