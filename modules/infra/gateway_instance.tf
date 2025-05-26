locals {
  # Generate the unique suffix for the template name
  gateway_suffix = "${replace(local.gateway_version, ".", "-")}-${substr(uuid(), 0, 8)}"
}
data "google_compute_image" "latest_image" {
  family  = local.gateway_vm_image_family
  project = local.gateway_vm_image_project
}
# Create an instance template
resource "google_compute_region_instance_template" "default_template" {
  for_each        = local.region_configs
  name         = "${local.name}-${local.region_configs[each.key].region_name}-gateway-template-${local.gateway_suffix}"
  machine_type = local.gateway_machine_type
  region       = local.region_configs[each.key].region_name

  disk {
    source_image = data.google_compute_image.latest_image.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = 50
    type         = "PERSISTENT"
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet[each.key].self_link
  }

  tags = local.gateway_vm_tags


  metadata = {
    "startup-script" = <<-EOT
    #!/bin/bash
    echo 'export GATEWAY_SECRET=${local.gateway_secret}' >> /etc/profile
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh ./get-docker.sh
    # Create necessary directories
    mkdir -p /etc/gateway/dynres
    mkdir -p /etc/gateway/config
    # Configure environment
    cat << EOF > /etc/gateway/config/app.env
    HARNESS_JWT_IDENTITY=CDEGateway
    HARNESS_JWT_VALIDINMIN=1440
    CDE_CLIENT_CONFIG_PATH=/etc/gateway/config/cdeclients.yaml
    ENVOY_DYNAMIC_RESOURCE_DIRECTORY=/etc/gateway/dynres
    GATEWAY_URL=${local.region_configs[each.key].certificates.contents[0].domain}
    GATEWAY_SECRET=${local.gateway_secret}
    HARNESS_JWT_SECRET=${local.gateway_secret}
    CDE_GATEWAY_REPORT_STATS=true
    CDE_GATEWAY_ACCOUNT_IDENTIFIER=${local.account_identifier}
    CDE_GATEWAY_INFRA_PROVIDER_CONFIG_IDENTIFIER=${local.infra_provider_config_identifier}
    CDE_GATEWAY_VERSION=${local.gateway_version}
    CDE_GATEWAY_REGION=${local.region_configs[each.key].region_name}
    CDE_GATEWAY_GROUP_NAME=${local.name}-${local.region_configs[each.key].region_name}-gateway-group-${local.gateway_suffix}
    EOF
    # Configure clients
    cat << YAML > /etc/gateway/config/cdeclients.yaml
    - base_url: ${local.cde_manager_url}
      secure: false
    YAML
    # Run Docker container as the non-root user
    sudo docker run -d \
    -e ENVOY_DYNAMIC_RESOURCE_DIRECTORY=/etc/gateway/dynres \
    -e CDE_CLIENT_CONFIG_PATH=/etc/gateway/config/cdeclients.yaml \
    -e CDE_GATEWAY_ENV_FILE=/etc/gateway/config/app.env \
    -e GATEWAY_AGENT_REQUIRE_MTLS=false \
    -e ENVOY_DEBUG_LEVEL=debug \
    -v /etc/gateway:/etc/gateway \
    --network host \
    harness/cde-gateway:${local.gateway_version}
  EOT
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_region_instance_group_manager" "gateway" {
  for_each = local.region_configs
  name     = "${local.name}-${each.value.region_name}-gateway-group-${local.gateway_suffix}"

  base_instance_name = "${local.name}-${each.value.region_name}-gateway-${local.gateway_suffix}"
  region             = each.value.region_name

  version {
    instance_template = google_compute_region_instance_template.default_template[each.key].self_link
  }

  target_size = local.gateway_instances

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 60
  }

  instance_lifecycle_policy {
    force_update_on_repair    = "YES"
    default_action_on_failure = "DO_NOTHING"
  }

  named_port {
    name = "http"
    port = 80
  }
  named_port {
    name = "gateway"
    port = 2117
  }

  depends_on = [google_compute_region_instance_template.default_template]

  lifecycle {
    create_before_destroy = true
  }
}