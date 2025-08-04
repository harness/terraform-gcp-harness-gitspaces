resource "google_redis_instance" "redis" {
  for_each                = local.enable_high_availability ? local.region_configs : {}
  name                    = "${local.name}-${local.region_configs[each.key].region_name}-redis"
  tier                    = "STANDARD_HA"
  memory_size_gb          = 1
  region                  = local.region_configs[each.key].region_name
  authorized_network      = google_compute_network.vpc_network.self_link
  replica_count           = 1
  redis_version           = "REDIS_7_0"
  display_name            = "Redis instance for cde-gateway"
  transit_encryption_mode = "DISABLED"
  auth_enabled            = false
}
