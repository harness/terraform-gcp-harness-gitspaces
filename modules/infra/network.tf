resource "google_compute_network" "vpc_network" {
  name                    = "${local.name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  for_each      = local.region_configs
  name          = "harnessdefault"
  ip_cidr_range = each.value.default_subnet_ip_range
  region        = each.value.region_name
  network       = google_compute_network.vpc_network.id
}

  module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = local.project_id
  network_name = google_compute_network.vpc_network.self_link

  egress_rules = [
    {
      name               = "${local.network_name}-allow-healthcheck-egress"
      description        = "Allow egress traffic for GCP healthchecks"
      direction          = "EGRESS"
      destination_ranges = ["0.0.0.0/0"] #  ["130.211.0.0/22", "35.191.0.0/16"]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
    },
    {
      name               = "${local.network_name}-allow-google-apis-egress"
      description        = "Allow egress traffic for GCP APIs"
      direction          = "EGRESS"
      destination_ranges = ["199.36.153.4/30"]
      allow = [{
        protocol = "all"
      }]
    },
    {
      name               = "${local.network_name}-allow-all-egress"
      description        = "Allow all egress traffic"
      direction          = "EGRESS"
      destination_ranges = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
    }
  ]

  ingress_rules = [
    {
      name          = "${local.network_name}-allow-healthcheck-ingress"
      description   = "Allow ingress traffic for GCP healthchecks"
      direction     = "INGRESS"
      priority      = "800"
      source_ranges = ["0.0.0.0/0"] #  ["130.211.0.0/22", "35.191.0.0/16"]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
    },
    {
      name          = "${local.network_name}-deny-all-ingress"
      description   = "Deny all ingress traffic to gitspace VMs"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      target_tags   = local.vm_tags_gitspace
      deny = [{
        protocol = "all"
      }]
    },
    {
      name          = "${local.network_name}-allow-ingress-gitspace"
      description   = "Allow all ingress traffic to gitspace from gateway"
      direction     = "INGRESS"
      priority      = 900

      source_ranges = ["10.0.0.0/8"]
      source_tags = local.gateway_vm_tags
      target_tags = local.vm_tags_gitspace

      allow = [{
        protocol = "tcp"
        ports = ["0-65535"]
      }]
    },
    {
      name          = "${local.network_name}-allow-gateway-ssh"
      description   = "Allow ssh to gateway"
      direction     = "INGRESS"
      priority      = 800

      source_ranges = ["35.235.240.0/20"]
      target_tags = concat(local.gateway_vm_tags, local.vm_tags_gitspace)

      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    {
      name          = "${local.network_name}-allow-all-ingress-gateway"
      description   = "Allow all ingress traffic to gateway"
      direction     = "INGRESS"
      priority      = 600
      source_ranges = concat(
    local.vm_ip_ranges,
    [for ip in google_compute_address.nat_static_ip : ip.address],
    [for ip in google_compute_address.alb_ip : ip.address],
    [for ip in google_compute_address.nlb_ip : ip.address]
      )
      target_tags   = local.gateway_vm_tags
      allow = [{
        protocol = "tcp"
        ports = ["80", "443", "2117", "2118", "2200-65000"]
      }]
    },

  ]
  depends_on = [google_compute_network.vpc_network]
}

resource "google_compute_address" "nat_static_ip" {
  for_each = local.region_configs

  name   = "${local.name}-${each.value.region_name}-nat-static-ip"
  region = each.value.region_name
  project = local.project_id
}

module "cloud_router" {
  for_each = local.region_configs

  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.1"

  name   = "${local.name}-${each.value.region_name}-gateway-router"
  region = each.value.region_name

  bgp = {
    asn = "65001"
  }

  nats = [
    {
      name                               = "${local.name}-${each.value.region_name}-gateway-nat",
      nat_ip_allocate_option             = "MANUAL_ONLY",
      nat_ips                            = [google_compute_address.nat_static_ip[each.key].self_link],
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES",
      log_config = {
        enable = true
        filter = "ERRORS_ONLY"
      }
    }
  ]

  project = local.project_id
  network = google_compute_network.vpc_network.name
}