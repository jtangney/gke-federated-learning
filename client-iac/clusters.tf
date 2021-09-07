module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google"
  project_id        = var.project_id
  name              = var.cluster_name_prefix
  regional          = false
  region            = var.region
  zones             = var.zones
  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.subnet.name
  ip_range_pods     = ""
  ip_range_services = ""
  service_account   = "create"
  node_pools = [
    {
      name         = "default-node-pool"
      autoscaling  = false
      auto_upgrade = true

      node_count   = var.client_cluster_node_count
      machine_type = var.client_cluster_machine_type
    },
  ]

  depends_on = [
    module.project-services
  ]
}