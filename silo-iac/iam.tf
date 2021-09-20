resource "google_service_account" "cluster_default_sa" {
  project      = var.project_id
  account_id   = local.cluster_default_sa_name
  display_name = "Default service account for cluster ${var.cluster_name}"
}

resource "google_service_account" "cluster_flpool_sa" {
  project      = var.project_id
  account_id   = local.fl_node_pool_sa_name
  display_name = "Service account for ${var.fl_node_pool_name} node pool in cluster ${var.cluster_name}"
}