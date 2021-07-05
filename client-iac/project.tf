resource "google_project" "project" {
  name       = var.project_id
  project_id = var.project_id
  org_id     = var.org_id
  billing_account = var.billing_account
  labels = {
    "purpose" = "tffe_client"
  }
}