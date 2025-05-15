output "vpc_network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "vpc_network" {
  description = "The provisioned VPC network"
  value       = google_compute_network.vpc_network
}

# Output for ALB IPs
output "alb_ips" {
  description = "The external IPs for the ALB"
  value = {
    for k, v in google_compute_address.alb_ip : k => v.address
  }
}

# Output for NLB IPs
output "nlb_ips" {
  description = "The external IPs for the NLB"
  value = {
    for k, v in google_compute_address.nlb_ip : k => v.address
  }
}

output "sub_networks" {
  value = google_compute_subnetwork.subnet
}