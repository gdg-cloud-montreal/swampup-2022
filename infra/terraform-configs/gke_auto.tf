# "dev-cluster"
resource "google_container_cluster" "auto1_cluster" {
  provider = google-beta
  project = var.gcp_project_id

  name               = "dev-cluster"
  min_master_version = var.kubernetes_version
  network            = google_compute_network.vpc_network.self_link
  subnetwork         = google_compute_subnetwork.gke_auto1_subnet.self_link

  location                    = var.gcp_region
  logging_service             = var.logging_service
  monitoring_service          = var.monitoring_service

# Enable Autopilot for this cluster
  enable_autopilot = true

# Configuration options for the Release channel feature, which provide more control over automatic upgrades of your GKE clusters.
  release_channel {
    channel = "REGULAR"
  }

# Configuration of cluster IP allocation for VPC-native clusters
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_auto1_cidr_name
    services_secondary_range_name = var.services_auto1_cidr_name
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
# "staging-cluster"
resource "google_container_cluster" "auto2_cluster" {
  provider = google-beta
  project = var.gcp_project_id

  name               = "staging-cluster"
  min_master_version = var.kubernetes_version
  network            = google_compute_network.vpc_network.self_link
  subnetwork         = google_compute_subnetwork.gke_auto2_subnet.self_link

  location                    = var.gcp_region
  logging_service             = var.logging_service
  monitoring_service          = var.monitoring_service

# Enable Autopilot for this cluster
  enable_autopilot = true

# Configuration options for the Release channel feature, which provide more control over automatic upgrades of your GKE clusters.
  release_channel {
    channel = "REGULAR"
  }

# Configuration of cluster IP allocation for VPC-native clusters
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_auto2_cidr_name
    services_secondary_range_name = var.services_auto2_cidr_name
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
# "prod-cluster"
resource "google_container_cluster" "auto3_cluster" {
  provider = google-beta
  project = var.gcp_project_id

  name               = "prod-cluster"
  min_master_version = var.kubernetes_version
  network            = google_compute_network.vpc_network.self_link
  subnetwork         = google_compute_subnetwork.gke_auto3_subnet.self_link

  location                    = var.gcp_region
  logging_service             = var.logging_service
  monitoring_service          = var.monitoring_service

# Enable Autopilot for this cluster
  enable_autopilot = true

# Configuration options for the Release channel feature, which provide more control over automatic upgrades of your GKE clusters.
  release_channel {
    channel = "REGULAR"
  }

# Configuration of cluster IP allocation for VPC-native clusters
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_auto3_cidr_name
    services_secondary_range_name = var.services_auto3_cidr_name
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}