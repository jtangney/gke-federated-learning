resource "google_service_account" "cluster_flpool_sa" {
  project      = var.project_id
  account_id   = local.fl_node_pool_sa_name
  display_name = "Service account for ${var.fl_node_pool_name} node pool in cluster ${var.cluster_name}"
}

resource "google_storage_bucket_iam_binding" "container_eu_pull_binding" {
  bucket = format("eu.artifacts.%s.appspot.com", var.project_id)
  role = "roles/storage.objectViewer"
  members = [
    # format("serviceAccount:%s", google_service_account.cluster_default_sa.email),
    format("serviceAccount:%s", google_service_account.cluster_flpool_sa.email)
  ]
}