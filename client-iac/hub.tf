module "hub-clients" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/hub"
  project_id       = google_project.project.project_id

  cluster_name     = module.client-cluster.name
  location         = module.client-cluster.location
  cluster_endpoint = module.client-cluster.endpoint
  gke_hub_membership_name = "${module.client-cluster.name}-client"
  gke_hub_sa_name = "${module.client-cluster.name}-client"
}