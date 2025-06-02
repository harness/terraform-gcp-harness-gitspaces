resource "google_compute_address" "alb_ip" {
  for_each     = local.region_configs
  name         = "${local.name}-${each.value.region_name}-alb-ip"
  address_type = "EXTERNAL"
  region       = each.value.region_name
}

resource "google_compute_address" "nlb_ip" {
  for_each     = local.region_configs
  name         = "${local.name}-${each.value.region_name}-nlb-ip"
  address_type = "EXTERNAL"
  region       = each.value.region_name
}

resource "google_compute_forwarding_rule" "nlb_default" {
  for_each        = local.region_configs
  name            = "${local.name}-${each.value.region_name}-default-nlb-frontend"
  ip_address      = google_compute_address.alb_ip[each.key].address
  ip_protocol     = "TCP"
  port_range      = "2200-65000"
  region          = each.value.region_name
  backend_service = google_compute_region_backend_service.nlb_default[each.key].id
}

resource "google_compute_region_backend_service" "nlb_default" {
  for_each              = local.region_configs
  name                  = "${local.name}-${each.value.region_name}-nlb-backend"
  region                = each.value.region_name
  protocol              = "TCP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL"
  dynamic "backend" {
    for_each = [google_compute_region_instance_group_manager.gateway[each.key].instance_group]
    content {
      balancing_mode = "CONNECTION"
      group          = backend.value
    }
  }
  health_checks = [google_compute_region_health_check.nlb_default[each.key].id]
}



resource "google_compute_region_health_check" "nlb_default" {
  for_each           = local.region_configs
  name               = "${local.name}-${each.value.region_name}-nlb-health-check"
  timeout_sec        = 5
  check_interval_sec = 5
  region             = each.value.region_name
  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_subnetwork" "proxy" {
  for_each      = local.region_configs
  name          = "${local.name}-${each.value.region_name}-proxy-subnet"
  ip_cidr_range = each.value.proxy_subnet_ip_range
  region        = each.value.region_name
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_forwarding_rule" "alb_default" {
  for_each              = local.region_configs
  name                  = "${local.name}-${each.value.region_name}-default-alb-frontend"
  port_range            = 443
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_address.alb_ip[each.key].address
  region                = each.value.region_name
  target                = google_compute_region_target_https_proxy.default[each.key].id
  network               = google_compute_network.vpc_network.self_link
  depends_on            = [google_compute_subnetwork.proxy]
}

resource "google_compute_region_target_https_proxy" "default" {
  for_each                         = local.region_configs
  name                             = "${local.name}-${each.value.region_name}-https-proxy"
  url_map                          = google_compute_region_url_map.default[each.key].id
  region                           = each.value.region_name

  certificate_manager_certificates = var.use_gcp_certificate_manager ? [
    "//certificatemanager.googleapis.com/projects/${local.project_id}/locations/${each.value.region_name}/certificates/${local.name}-${each.value.region_name}-dns-cert"] : null

  ssl_certificates = var.use_gcp_certificate_manager ? null : [
    google_compute_region_ssl_certificate.default[each.key].id ]
}

resource "google_compute_region_ssl_certificate" "default" {
  for_each    = var.use_gcp_certificate_manager == false ? local.region_configs : {}
  region      = local.region_configs[each.key].region_name
  name        = "${local.name}-certificate"
  private_key = file(var.private_key_path)
  certificate = file(var.certificate_path)
}

# url map
resource "google_compute_region_url_map" "default" {
  for_each        = local.region_configs
  name            = "${local.name}-${each.value.region_name}-url-map"
  region          = each.value.region_name
  default_service = google_compute_region_backend_service.alb_default[each.key].id
}

resource "google_compute_region_backend_service" "alb_default" {
  for_each              = local.region_configs
  name                  = "${local.name}-${each.value.region_name}-alb-backend"
  region                = each.value.region_name
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "http"
  dynamic "backend" {
    for_each = [google_compute_region_instance_group_manager.gateway[each.key].instance_group]
    content {
      balancing_mode        = "RATE"
      max_rate_per_instance = 100
      capacity_scaler       = 1.0
      group          = backend.value
    }
  }
  health_checks = [google_compute_region_health_check.alb_default[each.key].id]
}

resource "google_compute_region_health_check" "alb_default" {
  for_each           = local.region_configs
  name               = "${local.name}-${each.value.region_name}-health-check"
  timeout_sec        = 1
  check_interval_sec = 5
  region             = each.value.region_name
  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_forwarding_rule" "nlb_gateway_default" {
  for_each        = local.region_configs
  name            = "${local.name}-${each.value.region_name}-gateway-nlb-frontend"
  ip_address      = google_compute_address.alb_ip[each.key].address
  ip_protocol     = "TCP"
  port_range      = "2117-2118"
  region          = each.value.region_name
  backend_service = google_compute_region_backend_service.nlb_gateway_default[each.key].id
}

resource "google_compute_region_backend_service" "nlb_gateway_default" {
  for_each              = local.region_configs
  name                  = "${local.name}-${each.value.region_name}-gateway-nlb-backend"
  region                = each.value.region_name
  protocol              = "TCP"
  timeout_sec           = 10
  port_name             = "gateway"
  load_balancing_scheme = "EXTERNAL"

  dynamic "backend" {
    for_each = [google_compute_region_instance_group_manager.gateway[each.key].instance_group]
    content {
      balancing_mode = "CONNECTION"
      group          = backend.value
    }
  }
  health_checks = [google_compute_region_health_check.alb_default[each.key].id]
}