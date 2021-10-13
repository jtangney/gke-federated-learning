# Service Account used by the nodes in tenant node pool
resource "google_service_account" "tenant_nodepool_sa" {
  project      = var.project_id
  account_id   = local.tenant_nodepool_sa_name
  display_name = "Service account for ${local.tenant_nodepool_sa_name} node pool in cluster ${var.cluster_name}"
}

# Service Account used by apps in the tenant namespace
resource "google_service_account" "tenant_apps_sa" {
  project      = var.project_id
  account_id   = local.tenant_apps_sa_name
  display_name = "Service account for ${var.tenant_name} apps in cluster ${var.cluster_name}"
}

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

resource "google_service_account_iam_binding" "tenant" {
  service_account_id = google_service_account.tenant_apps_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    format("serviceAccount:%s.svc.id.goog[%s]", var.project_id, local.tenant_apps_ksa_name),
    # TESTING! Remove me
    format("serviceAccount:%s.svc.id.goog[%s]", var.project_id, "testing/ksa")
  ]
}
