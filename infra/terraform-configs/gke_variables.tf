# variables used to create GKE Cluster Control Plane

variable "kubernetes_version" {
  default     = ""
  type        = string
  description = "The GKE version of Kubernetes"
}

variable "logging_service" {
  description = "The logging service that the cluster should write logs to."
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  default     = "monitoring.googleapis.com/kubernetes"
  description = "The GCP monitoring service scope"
}

variable "release_channel" {
  type        = string
  default     = ""
  description = "The release channel of this cluster"
}

# variables used to create GKE AutoPilot Cluster Control Plane

variable "auto1_master_ipv4_cidr_block" {
  description = "The ipv4 cidr block that the GKE masters use"
}
variable "auto2_master_ipv4_cidr_block" {
  description = "The ipv4 cidr block that the GKE masters use"
}
variable "auto3_master_ipv4_cidr_block" {
  description = "The ipv4 cidr block that the GKE masters use"
}
