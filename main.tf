provider "google" {
  credentials = file(var.service_account_key_file)
  project     = local.project_id
}

module "infra" {
  source = "./modules/infra"
  infra_config_yaml_file = var.infra_config_yaml_file
  project_id = local.project_id
  use_gcp_certificate_manager = var.use_gcp_certificate_manager
  manage_dns_zone = var.manage_dns_zone
  private_key_path = var.private_key_path
  certificate_path = var.certificate_path
  create_runner_vm = var.create_runner_vm
  runner_vm_region = local.runner_vm_region
  depends_on = [module.domain]
}

module "domain" {
  count  = var.manage_dns_zone ? 1 : 0
  source = "./modules/domain"
  infra_config_yaml_file = var.infra_config_yaml_file
  project_id = local.project_id
  use_gcp_certificate_manager = var.use_gcp_certificate_manager
}