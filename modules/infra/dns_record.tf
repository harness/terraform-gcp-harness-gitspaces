# Create A record for the ALB
resource "google_dns_record_set" "alb_a" {
  for_each = var.manage_dns_zone ? local.region_configs : {}
  name         = "${local.region_configs[each.key].certificates.contents[0].domain}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.existing  # Global zone reference

  rrdatas = [google_compute_address.alb_ip[each.key].address]
}

# Create CNAME wildcard record for ALB
resource "google_dns_record_set" "alb_a_wildcard" {
  for_each = var.manage_dns_zone ? local.region_configs : {}
  name         = "*.${local.region_configs[each.key].certificates.contents[0].domain}."
  type         = "CNAME"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.existing.name   # Global zone reference

  rrdatas = ["${local.region_configs[each.key].certificates.contents[0].domain}."]
}

data "google_dns_managed_zone" "existing" {
  name = local.dns_managed_zone
}