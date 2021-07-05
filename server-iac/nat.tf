module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.2"
  project_id = var.project_id
  region     = var.region
  create_router = true
  network = google_compute_network.vpc.name
  router = "main-router"
}