# Service Account used by the nodes in FL node pool
resource "google_service_account" "tenant_nodepool_sa" {
  project      = var.project_id
  account_id   = local.tenant_nodepool_sa_name
  display_name = "Service account for ${local.tenant_nodepool_sa_name} node pool in cluster ${var.cluster_name}"
}

# resource "google_storage_bucket_iam_binding" "container_eu_pull_binding" {
#   bucket = format("eu.artifacts.%s.appspot.com", var.project_id)
#   role = "roles/storage.objectViewer"
#   members = [
#     # format("serviceAccount:%s", google_service_account.cluster_default_sa.email),
#     format("serviceAccount:%s", google_service_account.tenant_nodepool_sa.email)
#   ]
# }

module "project-iam-bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "authoritative"

  bindings = {
    "roles/logging.logWriter" = [
      format("serviceAccount:%s", google_service_account.tenant_nodepool_sa.email)
    ]
    "roles/monitoring.metricWriter" = [
      format("serviceAccount:%s", google_service_account.tenant_nodepool_sa.email)
    ]
    "roles/monitoring.viewer" = [
      format("serviceAccount:%s", google_service_account.tenant_nodepool_sa.email)
    ]
    "roles/artifactregistry.reader" = [
      format("serviceAccount:%s", google_service_account.tenant_nodepool_sa.email)
    ]
  }
}