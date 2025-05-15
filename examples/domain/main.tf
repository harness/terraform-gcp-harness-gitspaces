module "domain" {
  source = "./modules/domain"
  infra_config_yaml_file = var.infra_config_yaml_file
  project_id = local.project_id
  use_gcp_certificate_manager = var.use_gcp_certificate_manager
}


