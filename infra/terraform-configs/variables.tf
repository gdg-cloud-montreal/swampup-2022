variable "gcp_region" {
  type        = string
  description = "The GCP Region"
  default     = "us-central1"
}

variable "gcp_project_id" {
  type        = string
  description = "The newly created GCP project ID"
}

# Dev GKE Network 
variable "network_auto1_cidr" {
  type = string
}
variable "pods_auto1_cidr" {
  type = string
}
variable "pods_auto1_cidr_name" {
  type    = string
  default = "gke-auto1-pods"
}
variable "services_auto1_cidr" {
  type = string
}
variable "services_auto1_cidr_name" {
  type    = string
  default = "gke-auto1-services"
}
# Staging GKE Network 
variable "network_auto2_cidr" {
  type = string
}
variable "pods_auto2_cidr" {
  type = string
}
variable "pods_auto2_cidr_name" {
  type    = string
  default = "gke-auto2-pods"
}
variable "services_auto2_cidr" {
  type = string
}
variable "services_auto2_cidr_name" {
  type    = string
  default = "gke-auto2-services"
}

# Prod GKE Network
variable "network_auto3_cidr" {
  type = string
}
variable "pods_auto3_cidr" {
  type = string
}
variable "pods_auto3_cidr_name" {
  type    = string
  default = "gke-auto3-pods"
}
variable "services_auto3_cidr" {
  type = string
}
variable "services_auto3_cidr_name" {
  type    = string
  default = "gke-auto3-services"
}