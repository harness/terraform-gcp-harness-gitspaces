# Create a DNS Managed Zone (Global)
# Check if the DNS Managed Zone already exists

resource "google_dns_managed_zone" "default" {
  name        = local.dns_managed_zone
  dns_name    = "${local.domain}."
  description = "Managed DNS zone for ALB"
}