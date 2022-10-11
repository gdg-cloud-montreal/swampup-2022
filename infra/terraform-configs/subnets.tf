resource "google_compute_subnetwork" "gke_auto1_subnet" {
  name          = "gke-dev-cluster-subnet"
  network       = google_compute_network.vpc_network.self_link
  region        = var.gcp_region
  project       = var.gcp_project_id
  ip_cidr_range = var.network_auto1_cidr
  secondary_ip_range {
    range_name    = var.pods_auto1_cidr_name
    ip_cidr_range = var.pods_auto1_cidr
  }
  secondary_ip_range {
    range_name    = var.services_auto1_cidr_name
    ip_cidr_range = var.services_auto1_cidr
  }
   private_ip_google_access = true
   log_config {
     aggregation_interval = "INTERVAL_15_MIN"
     metadata             = "EXCLUDE_ALL_METADATA"
  }
}
resource "google_compute_subnetwork" "gke_auto2_subnet" {
  name          = "gke-staging-cluster-subnet"
  network       = google_compute_network.vpc_network.self_link
  region        = var.gcp_region
  project       = var.gcp_project_id
  ip_cidr_range = var.network_auto2_cidr
  secondary_ip_range {
    range_name    = var.pods_auto2_cidr_name
    ip_cidr_range = var.pods_auto2_cidr
  }
  secondary_ip_range {
    range_name    = var.services_auto2_cidr_name
    ip_cidr_range = var.services_auto2_cidr
  }
   private_ip_google_access = true
   log_config {
     aggregation_interval = "INTERVAL_15_MIN"
     metadata             = "EXCLUDE_ALL_METADATA"
  }
}
resource "google_compute_subnetwork" "gke_auto3_subnet" {
  name          = "gke-prod-cluster-subnet"
  network       = google_compute_network.vpc_network.self_link
  region        = var.gcp_region
  project       = var.gcp_project_id
  ip_cidr_range = var.network_auto3_cidr
  secondary_ip_range {
    range_name    = var.pods_auto3_cidr_name
    ip_cidr_range = var.pods_auto3_cidr
  }
  secondary_ip_range {
    range_name    = var.services_auto3_cidr_name
    ip_cidr_range = var.services_auto3_cidr
  }
   private_ip_google_access = true
   log_config {
     aggregation_interval = "INTERVAL_15_MIN"
     metadata             = "EXCLUDE_ALL_METADATA"
  }
}
