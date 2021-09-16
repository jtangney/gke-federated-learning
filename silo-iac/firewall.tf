
# // deny all egress from the FL node pool
# resource "google_compute_firewall" "flpool_deny_egress" {
#   name          = "flpool-deny-egress"
#   project       = var.project_id
#   network       = google_compute_network.vpc.name
#   direction     = "EGRESS"
#   source_service_accounts = [google_service_account.cluster_flpool_sa.email]
#   deny {
#     protocol = "all"
#   }
#   priority = 2000
# }

# // allow egress from FL node pool within the subnet
# // (higher priority than rule above)
# resource "google_compute_firewall" "flpool_allow_egress_within_subnet" {
#   name          = "flpool-allow-egress-within-subnet"
#   project       = var.project_id
#   network       = google_compute_network.vpc.name
#   direction     = "EGRESS"
#   source_service_accounts = [google_service_account.cluster_flpool_sa.email]
#   destination_ranges = [google_compute_subnetwork.subnet.ip_cidr_range]
#   allow {
#     protocol = "all"
#   }
#   priority = 1000
# }

// Dev / Testing
// Allow ssh tunnel-through-iap to all cluster nodes
resource "google_compute_firewall" "dev_allow_ssh_iap" {
  name          = "allow-ssh-iap"
  project       = var.project_id
  network       = google_compute_network.vpc.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = [var.cluster_name]
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  priority = 1000
}

// resource "google_compute_firewall" "webhook" {
//   name    = "allow-master-webhook"
//   network = google_compute_network.vpc.id

//   allow {
//     protocol = "tcp"
//     ports    = ["8443"]
//   }

//   source_ranges = ["${module.client-cluster.master_ipv4_cidr_block}"]
//   target_tags = [ "gke-${var.cluster_name_prefix}-client" ]
// }