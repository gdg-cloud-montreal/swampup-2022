resource "google_compute_network" "vpc_network" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  routing_mode            = "REGIONAL"
}
