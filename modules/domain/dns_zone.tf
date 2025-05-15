# Create a DNS Managed Zone (Global)
# Check if the DNS Managed Zone already exists

resource "google_dns_managed_zone" "default" {
  name        = replace(local.domain, ".", "-")
  dns_name    = "${local.domain}."
  description = "Managed DNS zone for ALB"
}