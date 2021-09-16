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

# module "nat" {
#   source  = "terraform-google-modules/cloud-router/google"
#   version = "~> 0.4"
#   project = var.project_id
#   name    = "fl-cloud-router"
#   network = google_compute_network.vpc.name
#   region  = google_compute_subnetwork.subnet.region

#   nats = [{
#     name = "fl-nat-gateway"
#   }]
# }

resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc.id
}

resource "google_compute_address" "nat_ip" {
  name   = "nat-manual-ip"
  region = google_compute_subnetwork.subnet.region
}

resource "google_compute_router_nat" "nat" {
  name   = "fl-nat-gateway"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.nat_ip.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}