module "acm-clients" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/acm?ref=v13.1.0"

  project_id       = google_project.project.project_id
  cluster_name     = module.client-cluster.name
  location         = module.client-cluster.location
  cluster_endpoint = module.client-cluster.endpoint

  operator_path    = "config-management-operator.yaml"
  sync_repo        = var.acm_repo_location
  sync_branch      = var.acm_branch
  policy_dir       = var.acm_dir
  secret_type      = var.acm_secret_type
  create_ssh_key   = var.acm_create_ssh_key
}