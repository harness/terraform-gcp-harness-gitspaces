output "managed_domain_zone" {
  description = "Managed Domain zone"
  value = google_dns_managed_zone.default.dns_name
}