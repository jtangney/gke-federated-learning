module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"

  project_id  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "anthos.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "cloudtrace.googleapis.com",
    "meshca.googleapis.com",
    "meshtelemetry.googleapis.com",
    "meshconfig.googleapis.com",
    "iamcredentials.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "stackdriver.googleapis.com"
  ]
}