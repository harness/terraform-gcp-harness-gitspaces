variable "project_id" {
  description = "The GCP project where resources will be created."
  type        = string
}

variable "infra_config_yaml_file" {
  description = "The path to the YAML file containing infrastructure configuration."
  type        = string
}

variable "action" {
  description = "The action to perform. Options are: create_infrastructure_only, deploy_gateway."
  type        = string

  validation {
    condition     = contains(["create_infrastructure_only", "deploy_gateway"], var.action)
    error_message = "Invalid value for resources. Must be one of: create_infrastructure_only, deploy_gateway."
  }
}

variable "use_gcp_certificate_manager" {
  description = "Use Google Certificate Manager for SSL certificates."
  type        = bool
  default     = true
}

variable "private_key_path" {
  description = "Path to the private key file for SSL certificate."
  type        = string
  default = ""
}

variable "certificate_path" {
  description = "Path to the SSL certificate file."
  type        = string
  default = ""
}

variable "manage_dns_zone" {
  description = "Manage DNS zone."
  type        = bool
  default     = false
}