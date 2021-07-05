# Client Clusters
module "client-cluster" {
  name                     = "${var.cluster_name_prefix}-client"
  project_id               = google_project.project.project_id
  source                   = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  regional                 = false
  region                   = var.region
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  ip_range_pods            = ""
  ip_range_services        = ""
  zones                    = var.zones
  release_channel          = "REGULAR"
  grant_registry_access    = true
  remove_default_node_pool = true
  cluster_resource_labels = { "mesh_id" : "proj-${google_project.project.project_id}" }
  enable_private_nodes    = true
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