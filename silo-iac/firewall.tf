
// deny all egress from the FL node pool
resource "google_compute_firewall" "flpool_deny_egress" {
  name          = "flpool-deny-egress"
  description   = "Default deny egress from node pool" 
  project       = var.project_id
  network       = google_compute_network.vpc.name
  direction     = "EGRESS"
  target_service_accounts = [google_service_account.cluster_flpool_sa.email]
  deny {
    protocol = "all"
  }
  priority = 65535
}

// allow egress from FL node pool within the subnet
# resource "google_compute_firewall" "flpool_allow_egress_within_subnet" {
#   name          = "flpool-allow-egress-within-subnet"
#   description   = "Allow egress from node pool within the subnet" 
#   project       = var.project_id
#   network       = google_compute_network.vpc.name
#   direction     = "EGRESS"
#   target_service_accounts = [google_service_account.cluster_flpool_sa.email]
#   destination_ranges = [google_compute_subnetwork.subnet.ip_cidr_range]
#   allow {
#     protocol = "all"
#   }
#   priority = 1000
# }

resource "google_compute_firewall" "flpool_allow_egress_nodes_pods_services" {
  name          = "flpool-allow-egress-nodes-pods-services"
  description   = "Allow egress from node pool to cluster nodes, pods and services" 
  project       = var.project_id
  network       = google_compute_network.vpc.name
  direction     = "EGRESS"
  target_service_accounts = [google_service_account.cluster_flpool_sa.email]
  destination_ranges = [google_compute_subnetwork.subnet.ip_cidr_range, "10.20.0.0/14", "10.24.0.0/20"]
  allow {
    protocol = "all"
  }
  priority = 1000
}

resource "google_compute_firewall" "flpool_allow_egress_api_server" {
  name          = "flpool-allow-egress-api-server"
  description   = "Allow egress from node pool to the Kubernetes API server" 
  project       = var.project_id
  network       = google_compute_network.vpc.name
  direction     = "EGRESS"
  target_service_accounts = [google_service_account.cluster_flpool_sa.email]
  destination_ranges = [var.master_ipv4_cidr_block]
  allow {
    protocol = "tcp"
    ports = [443, 10250]
  }
  priority = 1000
}

# resource "google_compute_firewall" "allow-healthcheck-ingress" {
#   name          = "allow-healthcheck-ingress"
#   project       = var.project_id
#   network       = google_compute_network.vpc.name
#   direction     = "INGRESS"
#   source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "209.85.204.0/22"]
#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"]
#   }
# }

# resource "google_compute_firewall" "allow-healthcheck-egress" {
#   name          = "allow-healthcheck-egress"
#   project       = var.project_id
#   network       = google_compute_network.vpc.name
#   direction     = "EGRESS"
#   target_service_accounts = [google_service_account.cluster_flpool_sa.email]
#   destination_ranges = ["130.211.0.0/22", "35.191.0.0/16", "209.85.204.0/22"]
#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"]
#   }
# }

# resource "google_compute_firewall" "flpool_allow_egress_calico" {
#   name          = "flpool-allow-egress-calico"
#   description   = "Allow Calico within the subnet" 
#   project       = var.project_id
#   network       = google_compute_network.vpc.name
#   direction     = "EGRESS"
#   target_service_accounts = [google_service_account.cluster_flpool_sa.email]
#   destination_ranges = [google_compute_subnetwork.subnet.ip_cidr_range]
#   allow {
#     protocol = "tcp"
#     ports = [5473]
#   }
#   priority = 1000
# }

resource "google_compute_firewall" "flpool_allow_egress_google_apis" {
  name          = "flpool-allow-egress-google-apis"
  description   = "Allow egress from node pool to Google APIs (private Google access)" 
  project       = var.project_id
  network       = google_compute_network.vpc.name
  direction     = "EGRESS"
  target_service_accounts = [google_service_account.cluster_flpool_sa.email]
  destination_ranges = ["199.36.153.8/30"]
  allow {
    protocol = "tcp"
  }
  priority = 1000
}

// Dev / Testing
// Allow ssh tunnel-through-iap to all cluster nodes
resource "google_compute_firewall" "allow-ssh-tunnel-iap" {
  name          = "allow-ssh-tunnel-iap"
  project       = var.project_id
  network       = google_compute_network.vpc.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["gke-${var.cluster_name}"]
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