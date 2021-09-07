resource "google_compute_network" "vpc" {
  name                    = "flsilo-network"
  project                 = var.project_id
  auto_create_subnetworks = false

  depends_on = [
    module.project-services
  ]
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-01"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
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