variable "project_id" {
  description = "The GCP project where resources will be created."
  type        = string
}

variable "infra_config_yaml_file" {
  description = "The path to the YAML file containing infrastructure configuration."
  type        = string
}

variable "use_gcp_certificate_manager" {
  description = "Use Google Certificate Manager for SSL certificates."
  type        = bool
  default     = true
}