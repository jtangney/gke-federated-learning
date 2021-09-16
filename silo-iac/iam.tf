resource "google_service_account" "cluster_default_sa" {
  project      = var.project_id
  account_id   = "gke-${var.cluster_name}-sa"
  display_name = "Default service account for cluster ${var.cluster_name}"
}

resource "google_service_account" "cluster_flpool_sa" {
  project      = var.project_id
  account_id   = "gke-${var.cluster_name}-${var.fl_node_pool_name}-sa"
  display_name = "Service account for ${var.fl_node_pool_name} node pool in cluster ${var.cluster_name}"
}