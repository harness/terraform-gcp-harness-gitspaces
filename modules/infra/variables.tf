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
    default     = true
}

variable "runner_vm_region" {
  description = "Regions for the runner VM."
  type        = list(string)
}

variable "create_runner_vm" {
    description = "Create a VM for the runner."
    type        = bool
}