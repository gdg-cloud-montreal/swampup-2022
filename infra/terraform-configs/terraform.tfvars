gcp_project_id = "swampup-2022" # Update Project ID with you project information

#gke-auto1 vars
network_auto1_cidr  = "10.128.0.0/23"
pods_auto1_cidr     = "10.0.0.0/16"
services_auto1_cidr = "10.100.0.0/23"
#gke-auto1 vars
network_auto2_cidr  = "10.129.0.0/23"
pods_auto2_cidr     = "10.2.0.0/16"
services_auto2_cidr = "10.100.2.0/23"
#gke-auto3 vars
network_auto3_cidr  = "10.130.0.0/23"
pods_auto3_cidr     = "10.4.0.0/16"
services_auto3_cidr = "10.100.4.0/23"
//gke autopilot specific
auto1_master_ipv4_cidr_block = "172.16.0.0/28"
auto2_master_ipv4_cidr_block = "172.16.0.16/28"
auto3_master_ipv4_cidr_block = "172.16.0.32/28"