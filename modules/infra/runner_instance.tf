resource "google_compute_instance" "runner_instance" {
  count        = var.create_runner_vm ? 1 : 0
  name         = "${local.name}-${local.runner_vm_region}-runner-${local.gateway_suffix}"
  machine_type = local.gateway_machine_type
  zone         = local.runner_vm_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.latest_image.self_link
      size  = 30
      type  = "pd-standard"
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet[local.runner_vm_region].self_link
  }

  tags = ["vm-runner"]

  lifecycle {
    create_before_destroy = true
  }
}
