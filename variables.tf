variable "service_account_key_file" {
  description = "The path to the service account key file."
  type        = string
}

variable "infra_config_yaml_file" {
  description = "The path to the YAML file containing infrastructure configuration."
  type        = string
}

variable "manage_dns_zone" {
  type = bool
}

variable "use_gcp_certificate_manager" {
  description = "Use Google Certificate Manager for SSL certificates."
  type        = bool
  default = true
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