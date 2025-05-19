# Verify end to end
resource "google_certificate_manager_dns_authorization" "default" {
  for_each = var.use_gcp_certificate_manager ? local.region_configs : {}
  name     = "${local.name}-${each.value.region_name}-default-wildcard-dns-auth"
  domain   = each.value.certificates.contents[0].domain
  location = each.value.region_name
  depends_on = [google_dns_managed_zone.default]
}

resource "google_dns_record_set" "default-challenge" {
  for_each = var.use_gcp_certificate_manager ? local.region_configs : {}
  name     = google_certificate_manager_dns_authorization.default[each.key].dns_resource_record[0].name
  type     = "CNAME"
  ttl      = 300

  managed_zone = local.dns_managed_zone

  rrdatas = [google_certificate_manager_dns_authorization.default[each.key].dns_resource_record[0].data]
  depends_on = [google_dns_managed_zone.default]
}

resource "google_certificate_manager_certificate" "default" {
  for_each    = var.use_gcp_certificate_manager ? local.region_configs : {}
  name        = "${local.name}-${each.value.region_name}-dns-cert"
  description = "The default cert"
  scope       = "DEFAULT"
  location    = each.value.region_name
  managed {
    domains = [
      "*.${google_certificate_manager_dns_authorization.default[each.key].domain}",
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default[each.key].id,
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [google_dns_managed_zone.default]
}
